package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.AuthDtos.UpdatePreferencesRequest;
import com.vibeconnect.dto.UserDto;
import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.UserRepository;
import com.vibeconnect.service.AuthService;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;
    private final AuthService authService;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AreaInfo {
        private String name;
        private long count;
        private String description;
    }

    @GetMapping("/matches")
    public ResponseEntity<ApiResponse<List<UserDto>>> getMatches(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) DatingIntent intent,
            @RequestParam(required = false) String gender) {

        String targetArea = area;
        if (targetArea == null || targetArea.isBlank()) {
            if (currentUser != null && currentUser.getPreferredArea() != null) {
                targetArea = currentUser.getPreferredArea();
            } else {
                targetArea = "Knowledge Park II";
            }
        }

        UUID currentUserId = currentUser != null ? currentUser.getId() : null;
        List<User> matchedUsers = userRepository.findMatches(currentUserId, targetArea.trim(), intent, gender);

        List<UserDto> dtos = matchedUsers.stream()
                .map(UserDto::fromEntity)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.ok("Found " + dtos.size() + " matches in " + targetArea, dtos));
    }

    @PutMapping("/preferences")
    public ResponseEntity<ApiResponse<UserDto>> updatePreferences(
            @AuthenticationPrincipal User currentUser,
            @RequestBody UpdatePreferencesRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        UserDto dto = authService.updatePreferences(currentUser, request);
        return ResponseEntity.ok(ApiResponse.ok("Preferences updated successfully", dto));
    }

    @GetMapping("/areas")
    public ResponseEntity<ApiResponse<List<AreaInfo>>> getAvailableAreas() {
        List<Object[]> rawCounts = userRepository.countUsersByArea();
        Map<String, Long> countMap = new HashMap<>();
        for (Object[] row : rawCounts) {
            if (row[0] != null) {
                countMap.put(row[0].toString(), (Long) row[1]);
            }
        }

        List<AreaInfo> predefined = Arrays.asList(
                AreaInfo.builder()
                        .name("Knowledge Park II")
                        .description("LIET & GL Bajaj Student Hub • Hostels & College cafes")
                        .count(countMap.getOrDefault("Knowledge Park II", 35L))
                        .build(),
                AreaInfo.builder()
                        .name("Pari Chowk")
                        .description("Central Greater Noida • Metro Station & Student Hub")
                        .count(countMap.getOrDefault("Pari Chowk", 25L))
                        .build(),
                AreaInfo.builder()
                        .name("Knowledge Park III")
                        .description("Sharda University Campus & International Student Hub")
                        .count(countMap.getOrDefault("Knowledge Park III", 20L))
                        .build(),
                AreaInfo.builder()
                        .name("Tech Zone II")
                        .description("Bennett University & Tech Park campus vibes")
                        .count(countMap.getOrDefault("Tech Zone II", 20L))
                        .build(),
                AreaInfo.builder()
                        .name("Sector 62 Noida")
                        .description("JIIT & Noida IT Corridor student zone")
                        .count(countMap.getOrDefault("Sector 62 Noida", 15L))
                        .build(),
                AreaInfo.builder()
                        .name("Sector 125 Noida")
                        .description("Amity University Campus & Sector 104 Cafe strip")
                        .count(countMap.getOrDefault("Sector 125 Noida", 15L))
                        .build(),
                AreaInfo.builder()
                        .name("Alpha 1 & Jagat Farm")
                        .description("Popular market food, student hostels & Maggi points")
                        .count(countMap.getOrDefault("Alpha 1 & Jagat Farm", 10L))
                        .build(),
                AreaInfo.builder()
                        .name("Yamuna Expressway")
                        .description("Galgotias & Gautam Buddha University campuses")
                        .count(countMap.getOrDefault("Yamuna Expressway", 10L))
                        .build()
        );

        return ResponseEntity.ok(ApiResponse.ok("Available areas fetched", predefined));
    }
}
