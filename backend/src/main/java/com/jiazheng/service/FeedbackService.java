package com.jiazheng.service;

import com.jiazheng.entity.Feedback;
import com.jiazheng.mapper.FeedbackRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FeedbackService {

    @Autowired
    private FeedbackRepository feedbackRepository;

    public Page<Feedback> getFeedbacks(Integer page, Integer pageSize, String keyword, String type, String status) {
        Pageable pageable = PageRequest.of(page, pageSize);
        List<Feedback> allFeedbacks = feedbackRepository.findAll();
        
        // 过滤
        List<Feedback> filtered = allFeedbacks.stream()
            .filter(f -> {
                // 关键词过滤
                if (keyword != null && !keyword.isEmpty()) {
                    boolean matchKeyword = (f.getUserName() != null && f.getUserName().contains(keyword)) ||
                                          (f.getTitle() != null && f.getTitle().contains(keyword)) ||
                                          (f.getContent() != null && f.getContent().contains(keyword));
                    if (!matchKeyword) return false;
                }
                // 类型过滤
                if (type != null && !type.isEmpty()) {
                    if (!type.equals(f.getType())) return false;
                }
                // 状态过滤
                if (status != null && !status.isEmpty()) {
                    if (!status.equals(f.getStatus())) return false;
                }
                return true;
            })
            .collect(Collectors.toList());
        
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<Feedback> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();
        
        return new PageImpl<>(pageContent, pageable, filtered.size());
    }

    public Feedback getFeedbackById(Long id) {
        Optional<Feedback> feedback = feedbackRepository.findById(id);
        return feedback.orElse(null);
    }

    public Feedback createFeedback(Feedback feedback) {
        feedback.setStatus("pending");
        feedback.setIsUrgent(0);
        return feedbackRepository.save(feedback);
    }

    public Feedback replyFeedback(Long id, String replyContent, String repliedBy) {
        Optional<Feedback> feedbackOpt = feedbackRepository.findById(id);
        if (feedbackOpt.isPresent()) {
            Feedback feedback = feedbackOpt.get();
            feedback.setReplyContent(replyContent);
            feedback.setRepliedBy(repliedBy);
            feedback.setRepliedAt(LocalDateTime.now());
            feedback.setStatus("resolved");
            return feedbackRepository.save(feedback);
        }
        return null;
    }

    public Feedback updateFeedbackStatus(Long id, String status) {
        Optional<Feedback> feedbackOpt = feedbackRepository.findById(id);
        if (feedbackOpt.isPresent()) {
            Feedback feedback = feedbackOpt.get();
            feedback.setStatus(status);
            return feedbackRepository.save(feedback);
        }
        return null;
    }

    public void deleteFeedback(Long id) {
        feedbackRepository.deleteById(id);
    }

    public Map<String, Object> getFeedbackStats() {
        List<Feedback> allFeedbacks = feedbackRepository.findAll();
        
        long total = allFeedbacks.size();
        long pending = allFeedbacks.stream().filter(f -> "pending".equals(f.getStatus())).count();
        long resolved = allFeedbacks.stream().filter(f -> "resolved".equals(f.getStatus())).count();
        
        // 计算满意度（假设已解决的反馈为满意）
        double satisfaction = total > 0 ? (double) resolved / total * 100 : 0;
        
        return Map.of(
            "total", total,
            "pending", pending,
            "resolved", resolved,
            "satisfaction", Math.round(satisfaction * 10) / 10.0
        );
    }
}
