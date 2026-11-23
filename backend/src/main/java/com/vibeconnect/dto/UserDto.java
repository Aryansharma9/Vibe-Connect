package com.vibeconnect.dto;

import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {
    private UUID id;
    private String phoneNumber;
    private String fullName;
    private String gender;
    private LocalDate dob;
    private CollegeDto college;
    private DatingIntent datingIntent;
    private String bio;
    private String collegeEmail;
    private Boolean isStudentVerified;
    private Boolean isPhotoVerified;
    private String avatarUrl;
    private String preferredArea;

    public static UserDto fromEntity(User u) {
        if (u == null) return null;
        return UserDto.builder()
                .id(u.getId())
                .phoneNumber(u.getPhoneNumber())
                .fullName(u.getFullName())
                .gender(u.getGender())
                .dob(u.getDob())
                .college(CollegeDto.fromEntity(u.getCollege()))
                .datingIntent(u.getDatingIntent())
                .bio(u.getBio())
                .collegeEmail(u.getCollegeEmail())
                .isStudentVerified(u.getIsStudentVerified())
                .isPhotoVerified(u.getIsPhotoVerified())
                .avatarUrl(u.getAvatarUrl())
                .preferredArea(u.getPreferredArea() != null ? u.getPreferredArea() : "Knowledge Park II")
                .build();
    }
}
