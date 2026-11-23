package com.vibeconnect.dto;

import com.vibeconnect.model.DatingIntent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

public class AuthDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RequestPhoneOtpRequest {
        @NotBlank(message = "Phone number is required")
        private String phoneNumber;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VerifyPhoneOtpRequest {
        @NotBlank(message = "Phone number is required")
        private String phoneNumber;

        @NotBlank(message = "OTP is required")
        private String otp;

        // Optional on registration, required if creating new profile
        private String fullName;
        private String gender;
        private LocalDate dob;
        private UUID collegeId;
        private DatingIntent datingIntent;
        private String preferredArea;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RegisterRequest {
        @NotBlank(message = "Phone number is required")
        private String phoneNumber;

        @NotBlank(message = "Full name is required")
        private String fullName;

        private String gender;
        private LocalDate dob;
        private UUID collegeId;
        private DatingIntent datingIntent;
        private String preferredArea;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdatePreferencesRequest {
        private String preferredArea;
        private DatingIntent datingIntent;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RequestCollegeEmailOtpRequest {
        @NotBlank(message = "College email is required")
        private String collegeEmail;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VerifyCollegeEmailOtpRequest {
        @NotBlank(message = "College email is required")
        private String collegeEmail;

        @NotBlank(message = "OTP is required")
        private String otp;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AuthResponse {
        private String accessToken;
        private String tokenType;
        private boolean isNewUser;
        private UserDto user;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ApiResponse<T> {
        private boolean success;
        private String message;
        private T data;

        public static <T> ApiResponse<T> ok(String message, T data) {
            return new ApiResponse<>(true, message, data);
        }

        public static <T> ApiResponse<T> fail(String message) {
            return new ApiResponse<>(false, message, null);
        }
    }
}
