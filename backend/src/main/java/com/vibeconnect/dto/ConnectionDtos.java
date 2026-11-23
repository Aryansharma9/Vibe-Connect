package com.vibeconnect.dto;

import com.vibeconnect.model.ConnectionRequest;
import com.vibeconnect.model.Conversation;
import com.vibeconnect.model.User;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

public class ConnectionDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SendConnectionRequest {
        @NotNull(message = "Target user ID is required")
        private UUID targetUserId;

        private String contextType; // 'PROMPT_ANSWER', 'PROFILE'
        private UUID contextId;
        private String contextSnippet;

        @Size(max = 140, message = "Note cannot exceed 140 characters")
        private String initialNote;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RespondRequest {
        @NotNull(message = "Action is required")
        private Boolean accept; // true for ACCEPTED, false for DECLINED
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ConnectionRequestDto {
        private UUID id;
        private UserDto sender;
        private UserDto receiver;
        private String contextType;
        private UUID contextId;
        private String contextSnippet;
        private String initialNote;
        private String status;
        private Instant createdAt;

        public static ConnectionRequestDto fromEntity(ConnectionRequest cr) {
            if (cr == null) return null;
            return ConnectionRequestDto.builder()
                    .id(cr.getId())
                    .sender(UserDto.fromEntity(cr.getSender()))
                    .receiver(UserDto.fromEntity(cr.getReceiver()))
                    .contextType(cr.getContextType())
                    .contextId(cr.getContextId())
                    .contextSnippet(cr.getContextSnippet())
                    .initialNote(cr.getInitialNote())
                    .status(cr.getStatus())
                    .createdAt(cr.getCreatedAt())
                    .build();
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ConversationDto {
        private UUID id;
        private UserDto otherUser;
        private Instant lastMessageAt;
        private Boolean isActive;
        private Instant createdAt;

        public static ConversationDto fromEntity(Conversation c, User currentUser) {
            if (c == null) return null;
            User other = c.getUserOne().getId().equals(currentUser.getId()) ? c.getUserTwo() : c.getUserOne();
            return ConversationDto.builder()
                    .id(c.getId())
                    .otherUser(UserDto.fromEntity(other))
                    .lastMessageAt(c.getLastMessageAt())
                    .isActive(c.getIsActive())
                    .createdAt(c.getCreatedAt())
                    .build();
        }
    }
}
