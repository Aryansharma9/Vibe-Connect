package com.vibeconnect.service;

import com.vibeconnect.dto.ModerationDtos.*;
import com.vibeconnect.model.Block;
import com.vibeconnect.model.Report;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.BlockRepository;
import com.vibeconnect.repository.ReportRepository;
import com.vibeconnect.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ModerationService {

    private final ReportRepository reportRepository;
    private final BlockRepository blockRepository;
    private final UserRepository userRepository;

    @Transactional
    public void reportUser(User reporter, ReportUserRequest req) {
        User reportedUser = userRepository.findById(req.getReportedUserId())
                .orElseThrow(() -> new IllegalArgumentException("Reported user not found"));

        Report report = Report.builder()
                .reporter(reporter)
                .reportedUser(reportedUser)
                .reason(req.getReason())
                .details(req.getDetails())
                .status("PENDING")
                .build();

        reportRepository.save(report);
        log.warn("🚨 SAFETY REPORT filed by [{}] against [{}] for reason: [{}]",
                reporter.getFullName(), reportedUser.getFullName(), req.getReason());
    }

    @Transactional
    public void blockUser(User blocker, UUID targetUserId) {
        User targetUser = userRepository.findById(targetUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!blockRepository.existsByBlockerAndBlockedUser(blocker, targetUser)) {
            Block block = Block.builder()
                    .blocker(blocker)
                    .blockedUser(targetUser)
                    .build();
            blockRepository.save(block);
            log.info("User [{}] blocked [{}]", blocker.getFullName(), targetUser.getFullName());
        }
    }

    public boolean isBlocked(User u1, User u2) {
        return blockRepository.existsByBlockerAndBlockedUser(u1, u2) ||
               blockRepository.existsByBlockerAndBlockedUser(u2, u1);
    }
}
