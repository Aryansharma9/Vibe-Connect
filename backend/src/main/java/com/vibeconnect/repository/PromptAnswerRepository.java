package com.vibeconnect.repository;

import com.vibeconnect.model.DailyQuestion;
import com.vibeconnect.model.DatingIntent;
import com.vibeconnect.model.PromptAnswer;
import com.vibeconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PromptAnswerRepository extends JpaRepository<PromptAnswer, UUID> {
    Optional<PromptAnswer> findByQuestionAndUser(DailyQuestion question, User user);
    boolean existsByQuestionAndUser(DailyQuestion question, User user);

    @Query("SELECT pa FROM PromptAnswer pa " +
           "WHERE pa.question = :question " +
           "AND (:collegeId IS NULL OR pa.user.college.id = :collegeId) " +
           "AND (:intent IS NULL OR pa.user.datingIntent = :intent) " +
           "ORDER BY pa.createdAt DESC")
    List<PromptAnswer> findFilteredAnswers(
            @Param("question") DailyQuestion question,
            @Param("collegeId") UUID collegeId,
            @Param("intent") DatingIntent intent);
}
