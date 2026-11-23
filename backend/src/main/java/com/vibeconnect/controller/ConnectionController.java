package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.ConnectionDtos.*;
import com.vibeconnect.model.User;
import com.vibeconnect.service.ConnectionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/connections")
@RequiredArgsConstructor
public class ConnectionController {

    private final ConnectionService connectionService;

    @PostMapping("/send")
    public ResponseEntity<ApiResponse<ConnectionRequestDto>> sendRequest(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody SendConnectionRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            ConnectionRequestDto dto = connectionService.sendConnectionRequest(currentUser, request);
            return ResponseEntity.ok(ApiResponse.ok("Connection request sent with personal note!", dto));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @GetMapping("/incoming")
    public ResponseEntity<ApiResponse<List<ConnectionRequestDto>>> getIncomingRequests(
            @AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        List<ConnectionRequestDto> requests = connectionService.getIncomingRequests(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Incoming connection requests", requests));
    }

    @GetMapping("/sent")
    public ResponseEntity<ApiResponse<List<ConnectionRequestDto>>> getSentRequests(
            @AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        List<ConnectionRequestDto> requests = connectionService.getSentRequests(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Sent connection requests", requests));
    }

    @GetMapping("/count")
    public ResponseEntity<ApiResponse<Long>> getPendingCount(
            @AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        long count = connectionService.getPendingRequestsCount(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Pending count", count));
    }

    @PostMapping("/{requestId}/respond")
    public ResponseEntity<ApiResponse<ConnectionRequestDto>> respondToRequest(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID requestId,
            @Valid @RequestBody RespondRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            ConnectionRequestDto dto = connectionService.respondToRequest(currentUser, requestId, request.getAccept());
            String message = Boolean.TRUE.equals(request.getAccept()) 
                    ? "Connection accepted! Private conversation unlocked." 
                    : "Connection request declined.";
            return ResponseEntity.ok(ApiResponse.ok(message, dto));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @GetMapping("/conversations")
    public ResponseEntity<ApiResponse<List<ConversationDto>>> getConversations(
            @AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        List<ConversationDto> conversations = connectionService.getUserConversations(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Unlocked conversations", conversations));
    }
}
