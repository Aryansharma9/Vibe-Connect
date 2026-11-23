package com.vibeconnect.repository;

import com.vibeconnect.model.VerificationCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VerificationCodeRepository extends JpaRepository<VerificationCode, UUID> {
    Optional<VerificationCode> findTopByRecipientAndTypeAndIsUsedFalseAndExpiresAtAfterOrderByCreatedAtDesc(
            String recipient, String type, Instant now);
}
