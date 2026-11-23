package com.vibeconnect.repository;

import com.vibeconnect.model.DailyQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DailyQuestionRepository extends JpaRepository<DailyQuestion, UUID> {
    Optional<DailyQuestion> findByActiveDate(LocalDate activeDate);
    Optional<DailyQuestion> findTopByOrderByActiveDateDesc();
}
