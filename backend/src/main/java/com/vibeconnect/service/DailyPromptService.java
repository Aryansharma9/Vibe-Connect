package com.vibeconnect.service;

import com.vibeconnect.dto.PromptDtos.*;
import com.vibeconnect.model.DailyQuestion;
import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.PromptAnswer;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.DailyQuestionRepository;
import com.vibeconnect.repository.PromptAnswerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DailyPromptService {

    private final DailyQuestionRepository dailyQuestionRepository;
    private final PromptAnswerRepository promptAnswerRepository;

    public DailyQuestion getOrCreateTodayQuestion() {
        LocalDate today = LocalDate.now();
        return dailyQuestionRepository.findByActiveDate(today)
                .orElseGet(() -> {
                    // Fallback to most recent question or auto-generate for today
                    return dailyQuestionRepository.findTopByOrderByActiveDateDesc()
                            .orElseGet(() -> dailyQuestionRepository.save(DailyQuestion.builder()
                                    .promptText("What is one campus spot where everyone goes, but you actually enjoy it?")
                                    .activeDate(today)
                                    .category("CAMPUS_LIFE")
                                    .build()));
                });
    }

    public DailyQuestionDto getTodayPromptStatus(User currentUser) {
        DailyQuestion question = getOrCreateTodayQuestion();
        boolean hasAnswered = false;
        PromptAnswer myAnswer = null;

        if (currentUser != null) {
            Optional<PromptAnswer> answerOpt = promptAnswerRepository.findByQuestionAndUser(question, currentUser);
            hasAnswered = answerOpt.isPresent();
            myAnswer = answerOpt.orElse(null);
        }

        return DailyQuestionDto.fromEntity(question, hasAnswered, myAnswer);
    }

    @Transactional
    public PromptAnswerDto submitAnswer(User currentUser, SubmitAnswerRequest req) {
        DailyQuestion question = dailyQuestionRepository.findById(req.getQuestionId())
                .orElseThrow(() -> new IllegalArgumentException("Question not found"));

        Optional<PromptAnswer> existingOpt = promptAnswerRepository.findByQuestionAndUser(question, currentUser);
        PromptAnswer answer;
        if (existingOpt.isPresent()) {
            answer = existingOpt.get();
            answer.setAnswerText(req.getAnswerText().trim());
            answer.setMediaUrl(req.getMediaUrl());
        } else {
            answer = PromptAnswer.builder()
                    .question(question)
                    .user(currentUser)
                    .answerText(req.getAnswerText().trim())
                    .mediaUrl(req.getMediaUrl())
                    .build();
        }

        PromptAnswer saved = promptAnswerRepository.save(answer);
        log.info("User [{}] posted an answer for prompt [{}]", currentUser.getFullName(), question.getId());
        return PromptAnswerDto.fromEntity(saved);
    }

    public List<PromptAnswerDto> getAnswersFeed(User currentUser, UUID questionId, boolean myCampusOnly, DatingIntent intentFilter) {
        DailyQuestion question = dailyQuestionRepository.findById(questionId)
                .orElseThrow(() -> new IllegalArgumentException("Question not found"));

        // CORE RECIPROCAL UNLOCK RULE:
        // User must answer first before seeing peers' moments!
        boolean hasAnswered = promptAnswerRepository.existsByQuestionAndUser(question, currentUser);
        if (!hasAnswered) {
            throw new IllegalStateException("Reciprocal unlock locked: You must answer today's question to view the campus feed!");
        }

        UUID collegeFilterId = null;
        if (myCampusOnly && currentUser.getCollege() != null) {
            collegeFilterId = currentUser.getCollege().getId();
        }

        List<PromptAnswer> answers = promptAnswerRepository.findFilteredAnswers(question, collegeFilterId, intentFilter);

        return answers.stream()
                // Put currentUser's own answer at the very top, followed by peers
                .sorted((a, b) -> {
                    if (a.getUser().getId().equals(currentUser.getId())) return -1;
                    if (b.getUser().getId().equals(currentUser.getId())) return 1;
                    return b.getCreatedAt().compareTo(a.getCreatedAt());
                })
                .map(PromptAnswerDto::fromEntity)
                .collect(Collectors.toList());
    }
}
