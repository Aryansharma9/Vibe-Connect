package com.vibeconnect.repository;

import com.vibeconnect.model.College;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CollegeRepository extends JpaRepository<College, UUID> {
    Optional<College> findByShortCodeIgnoreCase(String shortCode);
    List<College> findByCityIgnoreCase(String city);
    List<College> findByNameContainingIgnoreCase(String query);
}
