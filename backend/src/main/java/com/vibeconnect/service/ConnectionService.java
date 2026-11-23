package com.vibeconnect.service;

import com.vibeconnect.dto.ConnectionDtos.*;
import com.vibeconnect.model.ConnectionRequest;
import com.vibeconnect.model.Conversation;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.ConnectionRequestRepository;
import com.vibeconnect.repository.ConversationRepository;
import com.vibeconnect.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ConnectionService {

    private final ConnectionRequestRepository connectionRequestRepository;
    private final ConversationRepository conversationRepository;
    private final UserRepository userRepository;

    @Transactional
    public ConnectionRequestDto sendConnectionRequest(User sender, SendConnectionRequest req) {
        if (sender.getId().equals(req.getTargetUserId())) {
            throw new IllegalArgumentException("You cannot send a connection request to yourself");
        }

        User receiver = userRepository.findById(req.getTargetUserId())
                .orElseThrow(() -> new IllegalArgumentException("Target user not found"));

        // Check if a request already exists between these users
        Optional<ConnectionRequest> existing = connectionRequestRepository.findBySenderAndReceiver(sender, receiver);
        if (existing.isPresent()) {
            throw new IllegalStateException("A connection request to this student has already been sent");
        }

        ConnectionRequest request = ConnectionRequest.builder()
                .sender(sender)
                .receiver(receiver)
                .contextType(req.getContextType() != null ? req.getContextType() : "PROMPT_ANSWER")
                .contextId(req.getContextId())
                .contextSnippet(req.getContextSnippet())
                .initialNote(req.getInitialNote() != null ? req.getInitialNote().trim() : null)
                .status("PENDING")
                .build();

        ConnectionRequest saved = connectionRequestRepository.save(request);
        log.info("Student [{}] sent connection request to [{}] with note [{}]",
                sender.getFullName(), receiver.getFullName(), req.getInitialNote());

        return ConnectionRequestDto.fromEntity(saved);
    }

    public List<ConnectionRequestDto> getIncomingRequests(User receiver) {
        return connectionRequestRepository.findByReceiverAndStatusOrderByCreatedAtDesc(receiver, "PENDING")
                .stream()
                .map(ConnectionRequestDto::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ConnectionRequestDto> getSentRequests(User sender) {
        return connectionRequestRepository.findBySenderOrderByCreatedAtDesc(sender)
                .stream()
                .map(ConnectionRequestDto::fromEntity)
                .collect(Collectors.toList());
    }

    public long getPendingRequestsCount(User receiver) {
        return connectionRequestRepository.countByReceiverAndStatus(receiver, "PENDING");
    }

    @Transactional
    public ConnectionRequestDto respondToRequest(User receiver, UUID requestId, boolean accept) {
        ConnectionRequest request = connectionRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Connection request not found"));

        if (!request.getReceiver().getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("Unauthorized to respond to this request");
        }

        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new IllegalStateException("This request has already been " + request.getStatus().toLowerCase());
        }

        String newStatus = accept ? "ACCEPTED" : "DECLINED";
        request.setStatus(newStatus);
        request.setUpdatedAt(Instant.now());
        ConnectionRequest savedRequest = connectionRequestRepository.save(request);

        if (accept) {
            // Mutual consent: Automatically provision a private conversation room!
            Optional<Conversation> existingConv = conversationRepository.findBetweenUsers(request.getSender(), receiver);
            if (existingConv.isEmpty()) {
                Conversation conversation = Conversation.builder()
                        .connectionRequestId(savedRequest.getId())
                        .userOne(request.getSender())
                        .userTwo(receiver)
                        .lastMessageAt(Instant.now())
                        .isActive(true)
                        .build();
                conversationRepository.save(conversation);
                log.info("✨ Match made! Created conversation room between [{}] and [{}]",
                        request.getSender().getFullName(), receiver.getFullName());
            }
        }

        return ConnectionRequestDto.fromEntity(savedRequest);
    }

    public List<ConversationDto> getUserConversations(User user) {
        return conversationRepository.findActiveConversationsForUser(user)
                .stream()
                .map(c -> ConversationDto.fromEntity(c, user))
                .collect(Collectors.toList());
    }
}
