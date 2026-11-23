package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.ModerationDtos.*;
import com.vibeconnect.model.User;
import com.vibeconnect.service.ModerationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/moderation")
@RequiredArgsConstructor
public class ModerationController {

    private final ModerationService moderationService;

    @PostMapping("/report")
    public ResponseEntity<ApiResponse<String>> reportUser(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ReportUserRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            moderationService.reportUser(currentUser, request);
            return ResponseEntity.ok(ApiResponse.ok("Report submitted. Our campus moderators will investigate immediately.", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @PostMapping("/block")
    public ResponseEntity<ApiResponse<String>> blockUser(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody BlockUserRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            moderationService.blockUser(currentUser, request.getTargetUserId());
            return ResponseEntity.ok(ApiResponse.ok("User blocked. You will no longer see each other's profiles or moments.", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }
}
