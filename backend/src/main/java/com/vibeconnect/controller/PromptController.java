package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.PromptDtos.*;
import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.User;
import com.vibeconnect.service.DailyPromptService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/prompts")
@RequiredArgsConstructor
public class PromptController {

    private final DailyPromptService dailyPromptService;

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<DailyQuestionDto>> getTodayPrompt(
            @AuthenticationPrincipal User currentUser) {
        DailyQuestionDto dto = dailyPromptService.getTodayPromptStatus(currentUser);
        return ResponseEntity.ok(ApiResponse.ok("Today's prompt fetched", dto));
    }

    @PostMapping("/answer")
    public ResponseEntity<ApiResponse<PromptAnswerDto>> submitAnswer(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody SubmitAnswerRequest request) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            PromptAnswerDto dto = dailyPromptService.submitAnswer(currentUser, request);
            return ResponseEntity.ok(ApiResponse.ok("Answer posted! Campus feed unlocked.", dto));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }

    @GetMapping("/{questionId}/answers")
    public ResponseEntity<ApiResponse<List<PromptAnswerDto>>> getAnswersFeed(
            @AuthenticationPrincipal User currentUser,
            @PathVariable UUID questionId,
            @RequestParam(defaultValue = "false") boolean myCampusOnly,
            @RequestParam(required = false) DatingIntent intent) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(ApiResponse.fail("Unauthorized"));
        }
        try {
            List<PromptAnswerDto> feed = dailyPromptService.getAnswersFeed(currentUser, questionId, myCampusOnly, intent);
            return ResponseEntity.ok(ApiResponse.ok("Feed fetched successfully", feed));
        } catch (IllegalStateException e) {
            // Reciprocal unlock blocked
            return ResponseEntity.status(403).body(ApiResponse.fail(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.fail(e.getMessage()));
        }
    }
}
