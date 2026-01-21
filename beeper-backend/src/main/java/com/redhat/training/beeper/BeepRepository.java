package com.redhat.training.beeper;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BeepRepository extends JpaRepository<Beep, Long> {
    List<Beep> findAllByOrderByCreatedAtDesc();
}
