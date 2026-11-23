package com.vibeconnect.service;

import com.vibeconnect.dto.SpaceDtos.*;
import com.vibeconnect.model.Space;
import com.vibeconnect.model.SpacePost;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.SpacePostRepository;
import com.vibeconnect.repository.SpaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SpaceService {

    private final SpaceRepository spaceRepository;
    private final SpacePostRepository spacePostRepository;

    public List<SpaceDto> getAllSpaces() {
        return spaceRepository.findAll().stream()
                .map(SpaceDto::fromEntity)
                .collect(Collectors.toList());
    }

    public SpaceDto getSpaceById(UUID spaceId) {
        Space space = spaceRepository.findById(spaceId)
                .orElseThrow(() -> new IllegalArgumentException("Space not found"));
        return SpaceDto.fromEntity(space);
    }

    public List<SpacePostDto> getSpacePosts(UUID spaceId) {
        Space space = spaceRepository.findById(spaceId)
                .orElseThrow(() -> new IllegalArgumentException("Space not found"));
        return spacePostRepository.findBySpaceOrderByCreatedAtDesc(space).stream()
                .map(SpacePostDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public SpacePostDto createPost(User author, UUID spaceId, CreateSpacePostRequest req) {
        Space space = spaceRepository.findById(spaceId)
                .orElseThrow(() -> new IllegalArgumentException("Space not found"));

        SpacePost post = SpacePost.builder()
                .space(space)
                .user(author)
                .content(req.getContent().trim())
                .build();

        SpacePost saved = spacePostRepository.save(post);

        // Increment member/activity count
        space.setMemberCount(space.getMemberCount() != null ? space.getMemberCount() + 1 : 1);
        spaceRepository.save(space);

        log.info("Student [{}] posted in Space [{}]", author.getFullName(), space.getName());
        return SpacePostDto.fromEntity(saved);
    }
}
