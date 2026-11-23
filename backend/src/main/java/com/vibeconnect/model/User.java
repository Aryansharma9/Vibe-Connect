package com.vibeconnect.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "phone_number", nullable = false, unique = true)
    private String phoneNumber;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(nullable = false)
    private String gender;

    @Column(nullable = false)
    private LocalDate dob;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "college_id")
    private College college;

    @Enumerated(EnumType.STRING)
    @Column(name = "dating_intent", nullable = false)
    @Builder.Default
    private DatingIntent datingIntent = DatingIntent.GO_WITH_THE_FLOW;

    @Column(length = 500)
    private String bio;

    @Column(name = "college_email")
    private String collegeEmail;

    @Column(name = "is_student_verified")
    @Builder.Default
    private Boolean isStudentVerified = false;

    @Column(name = "is_photo_verified")
    @Builder.Default
    private Boolean isPhotoVerified = false;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(length = 20)
    @Builder.Default
    private String status = "ACTIVE";

    @Column(name = "created_at", updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
