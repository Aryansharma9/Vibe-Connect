package com.vibeconnect.service;

import com.vibeconnect.dto.ChatDtos.*;
import com.vibeconnect.model.Conversation;
import com.vibeconnect.model.Message;
import com.vibeconnect.model.User;
import com.vibeconnect.repository.ConversationRepository;
import com.vibeconnect.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public ChatMessageDto sendMessage(User sender, SendMessageRequest req) {
        Conversation conversation = conversationRepository.findById(req.getConversationId())
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        // Authorization check: User must be a participant in this conversation
        boolean isParticipant = conversation.getUserOne().getId().equals(sender.getId()) ||
                                conversation.getUserTwo().getId().equals(sender.getId());
        if (!isParticipant) {
            throw new IllegalArgumentException("Unauthorized to send message to this conversation");
        }

        Message message = Message.builder()
                .conversation(conversation)
                .sender(sender)
                .content(req.getContent().trim())
                .build();

        Message saved = messageRepository.save(message);

        // Update conversation last activity timestamp
        conversation.setLastMessageAt(Instant.now());
        conversationRepository.save(conversation);

        ChatMessageDto dto = ChatMessageDto.fromEntity(saved, sender);

        // Real-time broadcast to WebSocket topic
        String destination = "/topic/conversation." + conversation.getId();
        messagingTemplate.convertAndSend(destination, dto);

        log.info("Message sent in conversation [{}] by [{}]", conversation.getId(), sender.getFullName());
        return dto;
    }

    public List<ChatMessageDto> getConversationMessages(User currentUser, UUID conversationId) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        boolean isParticipant = conversation.getUserOne().getId().equals(currentUser.getId()) ||
                                conversation.getUserTwo().getId().equals(currentUser.getId());
        if (!isParticipant) {
            throw new IllegalArgumentException("Unauthorized to view this conversation");
        }

        return messageRepository.findByConversationOrderByCreatedAtAsc(conversation)
                .stream()
                .map(m -> ChatMessageDto.fromEntity(m, currentUser))
                .collect(Collectors.toList());
    }
}
