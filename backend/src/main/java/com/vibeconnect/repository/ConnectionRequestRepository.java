package com.vibeconnect.repository;

import com.vibeconnect.model.ConnectionRequest;
import com.vibeconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConnectionRequestRepository extends JpaRepository<ConnectionRequest, UUID> {
    List<ConnectionRequest> findByReceiverAndStatusOrderByCreatedAtDesc(User receiver, String status);
    List<ConnectionRequest> findBySenderOrderByCreatedAtDesc(User sender);
    Optional<ConnectionRequest> findBySenderAndReceiver(User sender, User receiver);
    boolean existsBySenderAndReceiver(User sender, User receiver);
    long countByReceiverAndStatus(User receiver, String status);
}
