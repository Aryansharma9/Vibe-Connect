package com.vibeconnect.service;

import com.vibeconnect.dto.AuthDtos.*;
import com.vibeconnect.dto.UserDto;
import com.vibeconnect.model.College;
import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.UserRepository;
import com.vibeconnect.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final CollegeService collegeService;
    private final OtpService otpService;
    private final JwtTokenProvider jwtTokenProvider;

    public String requestPhoneOtp(String phoneNumber) {
        return otpService.generateAndSaveOtp(phoneNumber, "PHONE_LOGIN");
    }

    @Transactional
    public AuthResponse verifyPhoneOtp(VerifyPhoneOtpRequest req) {
        boolean valid = otpService.verifyOtp(req.getPhoneNumber(), "PHONE_LOGIN", req.getOtp());
        if (!valid) {
            throw new IllegalArgumentException("Invalid or expired OTP");
        }

        Optional<User> existingUserOpt = userRepository.findByPhoneNumber(req.getPhoneNumber().trim());
        boolean isNew = existingUserOpt.isEmpty();

        User user;
        if (isNew) {
            if (req.getFullName() == null || req.getFullName().isBlank()) {
                // Returns without token indicating user profile needs to be created
                return AuthResponse.builder()
                        .isNewUser(true)
                        .accessToken(null)
                        .tokenType("Bearer")
                        .user(null)
                        .build();
            }

            College college = null;
            if (req.getCollegeId() != null) {
                college = collegeService.getCollegeById(req.getCollegeId());
            }

            user = User.builder()
                    .phoneNumber(req.getPhoneNumber().trim())
                    .fullName(req.getFullName().trim())
                    .gender(req.getGender() != null ? req.getGender() : "NOT_SPECIFIED")
                    .dob(req.getDob() != null ? req.getDob() : LocalDate.of(2003, 1, 1))
                    .college(college)
                    .datingIntent(req.getDatingIntent() != null ? req.getDatingIntent() : DatingIntent.GO_WITH_THE_FLOW)
                    .isStudentVerified(false)
                    .isPhotoVerified(false)
                    .status("ACTIVE")
                    .build();

            user = userRepository.save(user);
        } else {
            user = existingUserOpt.get();
        }

        String token = jwtTokenProvider.generateToken(user.getId(), user.getPhoneNumber());

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .isNewUser(false)
                .user(UserDto.fromEntity(user))
                .build();
    }

    @Transactional
    public AuthResponse registerProfile(RegisterRequest req) {
        College college = null;
        if (req.getCollegeId() != null) {
            college = collegeService.getCollegeById(req.getCollegeId());
        }

        Optional<User> existingUserOpt = userRepository.findByPhoneNumber(req.getPhoneNumber().trim());
        User user;
        if (existingUserOpt.isPresent()) {
            user = existingUserOpt.get();
            user.setFullName(req.getFullName().trim());
            if (req.getGender() != null) user.setGender(req.getGender());
            if (req.getDob() != null) user.setDob(req.getDob());
            if (college != null) user.setCollege(college);
            if (req.getDatingIntent() != null) user.setDatingIntent(req.getDatingIntent());
        } else {
            user = User.builder()
                    .phoneNumber(req.getPhoneNumber().trim())
                    .fullName(req.getFullName().trim())
                    .gender(req.getGender() != null ? req.getGender() : "NOT_SPECIFIED")
                    .dob(req.getDob() != null ? req.getDob() : LocalDate.of(2003, 1, 1))
                    .college(college)
                    .datingIntent(req.getDatingIntent() != null ? req.getDatingIntent() : DatingIntent.GO_WITH_THE_FLOW)
                    .isStudentVerified(false)
                    .isPhotoVerified(false)
                    .status("ACTIVE")
                    .build();
        }
        user = userRepository.save(user);

        String token = jwtTokenProvider.generateToken(user.getId(), user.getPhoneNumber());

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .isNewUser(false)
                .user(UserDto.fromEntity(user))
                .build();
    }

    public String requestCollegeEmailOtp(User currentUser, String collegeEmail) {
        if (currentUser.getCollege() == null) {
            throw new IllegalStateException("Please select your college first");
        }

        String domain = currentUser.getCollege().getEmailDomain();
        if (domain != null && !domain.isBlank() && !collegeEmail.toLowerCase().endsWith(domain.toLowerCase())) {
            throw new IllegalArgumentException(
                    "Email must end with your college domain (@" + domain + ")");
        }

        return otpService.generateAndSaveOtp(collegeEmail, "COLLEGE_EMAIL");
    }

    @Transactional
    public UserDto verifyCollegeEmailOtp(User currentUser, String collegeEmail, String otp) {
        boolean valid = otpService.verifyOtp(collegeEmail, "COLLEGE_EMAIL", otp);
        if (!valid) {
            throw new IllegalArgumentException("Invalid or expired verification code");
        }

        currentUser.setCollegeEmail(collegeEmail.trim().toLowerCase());
        currentUser.setIsStudentVerified(true);
        User saved = userRepository.save(currentUser);

        log.info("User [{}] successfully verified with college email [{}]", saved.getFullName(), collegeEmail);
        return UserDto.fromEntity(saved);
    }
}
