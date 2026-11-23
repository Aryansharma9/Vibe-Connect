package com.vibeconnect.repository;

import com.vibeconnect.model.Space;
import com.vibeconnect.model.SpacePost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SpacePostRepository extends JpaRepository<SpacePost, UUID> {
    List<SpacePost> findBySpaceOrderByCreatedAtDesc(Space space);
}
