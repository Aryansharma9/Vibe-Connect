package com.vibeconnect.dto;

import com.vibeconnect.model.College;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CollegeDto {
    private UUID id;
    private String name;
    private String shortCode;
    private String emailDomain;
    private String city;
    private String locality;

    public static CollegeDto fromEntity(College c) {
        if (c == null) return null;
        return CollegeDto.builder()
                .id(c.getId())
                .name(c.getName())
                .shortCode(c.getShortCode())
                .emailDomain(c.getEmailDomain())
                .city(c.getCity())
                .locality(c.getLocality())
                .build();
    }
}
