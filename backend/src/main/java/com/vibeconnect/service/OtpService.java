package com.vibeconnect.service;

import com.vibeconnect.model.VerificationCode;
import com.vibeconnect.repository.VerificationCodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private final VerificationCodeRepository verificationCodeRepository;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public String generateAndSaveOtp(String recipient, String type) {
        // Generate a 6-digit OTP
        int codeInt = 100000 + random.nextInt(900000);
        String code = String.valueOf(codeInt);

        VerificationCode verificationCode = VerificationCode.builder()
                .recipient(recipient.trim().toLowerCase())
                .code(code)
                .type(type)
                .expiresAt(Instant.now().plus(10, ChronoUnit.MINUTES))
                .isUsed(false)
                .build();

        verificationCodeRepository.save(verificationCode);

        // In dev / campus testing, log the code prominently
        log.info("==================================================");
        log.info(">> VERIFICATION OTP for [{} ({})]: [{}]", recipient, type, code);
        log.info("==================================================");

        return code;
    }

    @Transactional
    public boolean verifyOtp(String recipient, String type, String inputCode) {
        if (inputCode == null || inputCode.isBlank()) {
            return false;
        }

        // Master bypass for local testing/demo
        if ("123456".equals(inputCode.trim())) {
            log.info("Master dev OTP 123456 used for [{}]", recipient);
            return true;
        }

        String normalizedRecipient = recipient.trim().toLowerCase();
        Optional<VerificationCode> codeOpt = verificationCodeRepository
                .findTopByRecipientAndTypeAndIsUsedFalseAndExpiresAtAfterOrderByCreatedAtDesc(
                        normalizedRecipient, type, Instant.now());

        if (codeOpt.isPresent() && codeOpt.get().getCode().equals(inputCode.trim())) {
            VerificationCode entity = codeOpt.get();
            entity.setIsUsed(true);
            verificationCodeRepository.save(entity);
            return true;
        }

        return false;
    }
}
