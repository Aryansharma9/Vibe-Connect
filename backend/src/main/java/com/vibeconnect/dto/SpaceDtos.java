package com.vibeconnect.dto;

import com.vibeconnect.model.Space;
import com.vibeconnect.model.SpacePost;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

public class SpaceDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SpaceDto {
        private UUID id;
        private String name;
        private String slug;
        private String icon;
        private String description;
        private String category;
        private Integer memberCount;

        public static SpaceDto fromEntity(Space s) {
            if (s == null) return null;
            return SpaceDto.builder()
                    .id(s.getId())
                    .name(s.getName())
                    .slug(s.getSlug())
                    .icon(s.getIcon())
                    .description(s.getDescription())
                    .category(s.getCategory())
                    .memberCount(s.getMemberCount())
                    .build();
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SpacePostDto {
        private UUID id;
        private UUID spaceId;
        private UserDto user;
        private String content;
        private Instant createdAt;

        public static SpacePostDto fromEntity(SpacePost p) {
            if (p == null) return null;
            return SpacePostDto.builder()
                    .id(p.getId())
                    .spaceId(p.getSpace().getId())
                    .user(UserDto.fromEntity(p.getUser()))
                    .content(p.getContent())
                    .createdAt(p.getCreatedAt())
                    .build();
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateSpacePostRequest {
        @NotBlank(message = "Post content cannot be empty")
        @Size(max = 500, message = "Post cannot exceed 500 characters")
        private String content;
    }
}
