package com.vibeconnect.controller;

import com.vibeconnect.dto.AuthDtos.ApiResponse;
import com.vibeconnect.dto.CollegeDto;
import com.vibeconnect.service.CollegeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/colleges")
@RequiredArgsConstructor
public class CollegeController {

    private final CollegeService collegeService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<CollegeDto>>> getColleges(
            @RequestParam(required = false) String search) {
        List<CollegeDto> colleges = collegeService.searchColleges(search);
        return ResponseEntity.ok(ApiResponse.ok("Colleges fetched successfully", colleges));
    }
}
