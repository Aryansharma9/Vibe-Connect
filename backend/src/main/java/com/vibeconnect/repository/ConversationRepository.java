package com.vibeconnect.repository;

import com.vibeconnect.model.Conversation;
import com.vibeconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConversationRepository extends JpaRepository<Conversation, UUID> {

    @Query("SELECT c FROM Conversation c " +
           "WHERE (c.userOne = :user OR c.userTwo = :user) AND c.isActive = true " +
           "ORDER BY c.lastMessageAt DESC")
    List<Conversation> findActiveConversationsForUser(@Param("user") User user);

    @Query("SELECT c FROM Conversation c " +
           "WHERE ((c.userOne = :u1 AND c.userTwo = :u2) OR (c.userOne = :u2 AND c.userTwo = :u1)) " +
           "AND c.isActive = true")
    Optional<Conversation> findBetweenUsers(@Param("u1") User u1, @Param("u2") User u2);
}
