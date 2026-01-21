package com.redhat.training.beeper;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IncidentRepository extends JpaRepository<Incident, Long> {
    List<Incident> findAllByOrderByCreatedAtDesc();
    List<Incident> findByStatus(Status status);
    List<Incident> findBySeverity(Severity severity);
}
