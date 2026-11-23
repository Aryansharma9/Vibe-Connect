package com.vibeconnect.dto;

import com.vibeconnect.model.Message;
import com.vibeconnect.model.User;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

public class ChatDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SendMessageRequest {
        @NotNull(message = "Conversation ID is required")
        private UUID conversationId;

        @NotBlank(message = "Message content cannot be blank")
        private String content;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChatMessageDto {
        private UUID id;
        private UUID conversationId;
        private UUID senderId;
        private String senderName;
        private String content;
        private Instant createdAt;
        private boolean isMine;

        public static ChatMessageDto fromEntity(Message m, User currentUser) {
            if (m == null) return null;
            boolean mine = currentUser != null && m.getSender().getId().equals(currentUser.getId());
            return ChatMessageDto.builder()
                    .id(m.getId())
                    .conversationId(m.getConversation().getId())
                    .senderId(m.getSender().getId())
                    .senderName(m.getSender().getFullName())
                    .content(m.getContent())
                    .createdAt(m.getCreatedAt())
                    .isMine(mine)
                    .build();
        }
    }
}
