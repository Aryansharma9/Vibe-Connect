package com.vibeconnect.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

public class ModerationDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReportUserRequest {
        @NotNull(message = "Reported user ID is required")
        private UUID reportedUserId;

        @NotBlank(message = "Reason is required")
        private String reason; // SCAM, HARASSMENT, FAKE_PROFILE, OTHER

        private String details;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BlockUserRequest {
        @NotNull(message = "Target user ID is required")
        private UUID targetUserId;
    }
}
