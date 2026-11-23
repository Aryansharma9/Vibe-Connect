package com.vibeconnect.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "daily_questions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "prompt_text", nullable = false, columnDefinition = "TEXT")
    private String promptText;

    @Column(name = "active_date", nullable = false, unique = true)
    private LocalDate activeDate;

    @Column(length = 50)
    @Builder.Default
    private String category = "VIBE";

    @Column(name = "created_at", updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
