package com.vibeconnect.service;

import com.vibeconnect.dto.CollegeDto;
import com.vibeconnect.model.College;
import com.vibeconnect.repository.CollegeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CollegeService {

    private final CollegeRepository collegeRepository;

    public List<CollegeDto> getAllColleges() {
        return collegeRepository.findAll().stream()
                // Sort so LIET (our campus) always appears first, then alphabetically
                .sorted(Comparator.comparing((College c) -> !"LIET".equalsIgnoreCase(c.getShortCode()))
                        .thenComparing(College::getName))
                .map(CollegeDto::fromEntity)
                .collect(Collectors.toList());
    }

    public List<CollegeDto> searchColleges(String query) {
        if (query == null || query.isBlank()) {
            return getAllColleges();
        }
        return collegeRepository.findByNameContainingIgnoreCase(query.trim()).stream()
                .map(CollegeDto::fromEntity)
                .collect(Collectors.toList());
    }

    public College getCollegeById(UUID id) {
        return collegeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("College not found with id: " + id));
    }
}
