package com.redhat.training.beeper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/beeps")
@CrossOrigin(origins = "*")
public class BeepController {

    @Autowired
    private BeepRepository beepRepository;

    @GetMapping
    public ResponseEntity<List<Beep>> getAllBeeps() {
        List<Beep> beeps = beepRepository.findAllByOrderByCreatedAtDesc();
        return ResponseEntity.ok(beeps);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Beep> getBeepById(@PathVariable Long id) {
        return beepRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Beep> createBeep(@RequestBody Beep beep) {
        if (beep.getMessage() == null || beep.getMessage().trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        if (beep.getAuthor() == null || beep.getAuthor().trim().isEmpty()) {
            beep.setAuthor("Anonymous");
        }
        Beep savedBeep = beepRepository.save(beep);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedBeep);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBeep(@PathVariable Long id) {
        if (beepRepository.existsById(id)) {
            beepRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
