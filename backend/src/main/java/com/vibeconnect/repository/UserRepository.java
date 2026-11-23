package com.vibeconnect.repository;

import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByPhoneNumber(String phoneNumber);
    Optional<User> findByCollegeEmail(String collegeEmail);
    boolean existsByPhoneNumber(String phoneNumber);

    List<User> findByPreferredAreaIgnoreCase(String preferredArea);

    @Query("SELECT u FROM User u WHERE (:currentUserId IS NULL OR u.id != :currentUserId) " +
           "AND (:area IS NULL OR LOWER(u.preferredArea) = LOWER(:area)) " +
           "AND (:intent IS NULL OR u.datingIntent = :intent) " +
           "AND (:gender IS NULL OR u.gender = :gender) " +
           "ORDER BY u.isStudentVerified DESC, u.createdAt DESC")
    List<User> findMatches(
            @Param("currentUserId") UUID currentUserId,
            @Param("area") String area,
            @Param("intent") DatingIntent intent,
            @Param("gender") String gender);

    @Query("SELECT u.preferredArea, COUNT(u) FROM User u WHERE u.preferredArea IS NOT NULL GROUP BY u.preferredArea")
    List<Object[]> countUsersByArea();
}
