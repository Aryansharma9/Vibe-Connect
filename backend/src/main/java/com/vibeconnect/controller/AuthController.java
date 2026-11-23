package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.*;
import com.vibeconnect.dto.UserDto;
import com.vibeconnect.model.User;
import com.vibeconnect.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/phone/otp")
    public ResponseEntity<ApiResponse<String>> requestPhoneOtp(
            @Valid @RequestBody RequestPhoneOtpRequest request) {
        String code = authService.requestPhoneOtp(request.getPhoneNumber());
        return ResponseEntity.ok(ApiResponse.ok("OTP sent successfully. (Dev code: " + code + ")", code));
    }

    @PostMapping("/phone/verify")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyPhoneOtp(
            @Valid @RequestBody VerifyPhoneOtpRequest request) {
        try {
            AuthResponse response = authService.verifyPhoneOtp(request);
            return ResponseEntity.ok(ApiResponse.ok("Verified successfully", response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @PostMapping("/college-email/otp")
    public ResponseEntity<ApiResponse<String>> requestCollegeEmailOtp(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody RequestCollegeEmailOtpRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            String code = authService.requestCollegeEmailOtp(currentUser, request.getCollegeEmail());
            return ResponseEntity.ok(ApiResponse.ok(
                    "Verification code sent to " + request.getCollegeEmail() + ". (Dev code: " + code + ")", code));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @PostMapping("/college-email/verify")
    public ResponseEntity<ApiResponse<UserDto>> verifyCollegeEmailOtp(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody VerifyCollegeEmailOtpRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            UserDto updatedUser = authService.verifyCollegeEmailOtp(
                    currentUser, request.getCollegeEmail(), request.getOtp());
            return ResponseEntity.ok(ApiResponse.ok("College email verified! You are now a Verified Student.", updatedUser));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        return ResponseEntity.ok(ApiResponse.ok("Current user profile", UserDto.fromEntity(currentUser)));
    }
}
