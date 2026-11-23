package com.vibeconnect.repository;

import com.vibeconnect.model.Block;
import com.vibeconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BlockRepository extends JpaRepository<Block, UUID> {
    boolean existsByBlockerAndBlockedUser(User blocker, User blockedUser);
    Optional<Block> findByBlockerAndBlockedUser(User blocker, User blockedUser);
}
