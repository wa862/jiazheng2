package com.jiazheng.mapper;

import com.jiazheng.entity.Feedback;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    List<Feedback> findByStatus(String status);
    List<Feedback> findByType(String type);
    List<Feedback> findByUserId(Long userId);
}
