package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.SpaceDtos.*;
import com.vibeconnect.model.User;
import com.vibeconnect.service.SpaceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/spaces")
@RequiredArgsConstructor
public class SpaceController {

    private final SpaceService spaceService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<SpaceDto>>> getAllSpaces() {
        List<SpaceDto> spaces = spaceService.getAllSpaces();
        return ResponseEntity.ok(ApiResponse.ok("Spaces fetched", spaces));
    }

    @GetMapping("/{spaceId}")
    public ResponseEntity<ApiResponse<SpaceDto>> getSpace(@PathVariable UUID spaceId) {
        SpaceDto space = spaceService.getSpaceById(spaceId);
        return ResponseEntity.ok(ApiResponse.ok("Space fetched", space));
    }

    @GetMapping("/{spaceId}/posts")
    public ResponseEntity<ApiResponse<List<SpacePostDto>>> getSpacePosts(@PathVariable UUID spaceId) {
        List<SpacePostDto> posts = spaceService.getSpacePosts(spaceId);
        return ResponseEntity.ok(ApiResponse.ok("Space posts fetched", posts));
    }

    @PostMapping("/{spaceId}/posts")
    public ResponseEntity<ApiResponse<SpacePostDto>> createPost(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID spaceId,
            @Valid @RequestBody CreateSpacePostRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            SpacePostDto post = spaceService.createPost(currentUser, spaceId, request);
            return ResponseEntity.ok(ApiResponse.ok("Post published in space", post));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }
}
