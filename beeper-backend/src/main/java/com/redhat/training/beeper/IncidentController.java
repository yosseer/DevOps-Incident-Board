package com.redhat.training.beeper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/incidents")
@CrossOrigin(origins = "*")
public class IncidentController {

    @Autowired
    private IncidentRepository incidentRepository;

    @GetMapping
    public ResponseEntity<List<Incident>> getAllIncidents() {
        List<Incident> incidents = incidentRepository.findAllByOrderByCreatedAtDesc();
        return ResponseEntity.ok(incidents);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Incident> getIncidentById(@PathVariable Long id) {
        return incidentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Incident> createIncident(@RequestBody Incident incident) {
        if (incident.getTitle() == null || incident.getTitle().trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        if (incident.getCreatedBy() == null || incident.getCreatedBy().trim().isEmpty()) {
            incident.setCreatedBy("Anonymous");
        }
        if (incident.getSeverity() == null) {
            incident.setSeverity(Severity.MEDIUM);
        }
        if (incident.getStatus() == null) {
            incident.setStatus(Status.OPEN);
        }
        Incident savedIncident = incidentRepository.save(incident);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedIncident);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Incident> updateIncidentStatus(
            @PathVariable Long id, 
            @RequestBody Map<String, String> statusUpdate) {
        
        java.util.Optional<Incident> optionalIncident = incidentRepository.findById(id);
        if (!optionalIncident.isPresent()) {
            return ResponseEntity.notFound().build();
        }
        
        Incident incident = optionalIncident.get();
        try {
            Status newStatus = Status.valueOf(statusUpdate.get("status"));
            incident.setStatus(newStatus);
            
            // Handle resolution fields
            if (newStatus == Status.RESOLVED) {
                incident.setResolutionComment(statusUpdate.get("resolutionComment"));
                incident.setResolvedBy(statusUpdate.get("resolvedBy"));
                String resolvedAtStr = statusUpdate.get("resolvedAt");
                if (resolvedAtStr != null) {
                    incident.setResolvedAt(LocalDateTime.parse(resolvedAtStr.replace("Z", "")));
                } else {
                    incident.setResolvedAt(LocalDateTime.now());
                }
            } else {
                // Clear resolution fields if reopening
                incident.setResolutionComment(null);
                incident.setResolvedBy(null);
                incident.setResolvedAt(null);
            }
            
            Incident updatedIncident = incidentRepository.save(incident);
            return ResponseEntity.ok(updatedIncident);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteIncident(@PathVariable Long id) {
        if (incidentRepository.existsById(id)) {
            incidentRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
