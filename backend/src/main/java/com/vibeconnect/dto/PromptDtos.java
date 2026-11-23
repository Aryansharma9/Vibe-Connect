package com.vibeconnect.dto;

import com.vibeconnect.model.DailyQuestion;
import com.vibeconnect.model.PromptAnswer;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class PromptDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyQuestionDto {
        private UUID id;
        private String promptText;
        private LocalDate activeDate;
        private String category;
        private boolean hasAnswered;
        private PromptAnswerDto myAnswer;

        public static DailyQuestionDto fromEntity(DailyQuestion q, boolean hasAnswered, PromptAnswer myAnswer) {
            return DailyQuestionDto.builder()
                    .id(q.getId())
                    .promptText(q.getPromptText())
                    .activeDate(q.getActiveDate())
                    .category(q.getCategory())
                    .hasAnswered(hasAnswered)
                    .myAnswer(myAnswer != null ? PromptAnswerDto.fromEntity(myAnswer) : null)
                    .build();
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PromptAnswerDto {
        private UUID id;
        private UUID questionId;
        private UserDto user;
        private String answerText;
        private String mediaUrl;
        private Instant createdAt;

        public static PromptAnswerDto fromEntity(PromptAnswer pa) {
            if (pa == null) return null;
            return PromptAnswerDto.builder()
                    .id(pa.getId())
                    .questionId(pa.getQuestion() != null ? pa.getQuestion().getId() : null)
                    .user(UserDto.fromEntity(pa.getUser()))
                    .answerText(pa.getAnswerText())
                    .mediaUrl(pa.getMediaUrl())
                    .createdAt(pa.getCreatedAt())
                    .build();
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SubmitAnswerRequest {
        @NotNull(message = "Question ID is required")
        private UUID questionId;

        @NotBlank(message = "Answer text cannot be empty")
        @Size(max = 280, message = "Answer cannot exceed 280 characters")
        private String answerText;

        private String mediaUrl;
    }
}
