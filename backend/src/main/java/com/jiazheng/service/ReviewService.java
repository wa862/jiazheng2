package com.jiazheng.service;

import com.jiazheng.entity.Review;
import com.jiazheng.entity.Worker;
import com.jiazheng.mapper.ReviewRepository;
import com.jiazheng.mapper.WorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private WorkerRepository workerRepository;

    @Transactional
    public Review createReview(Review review) {
        Review savedReview = reviewRepository.save(review);

        updateWorkerRating(review.getWorkerId());

        return savedReview;
    }

    public Optional<Review> getReviewById(Long id) {
        return reviewRepository.findById(id);
    }

    public List<Review> getReviewsByWorkerId(Long workerId) {
        return reviewRepository.findByWorkerId(workerId);
    }

    public Page<Review> getReviewsByWorkerId(Long workerId, Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        return reviewRepository.findByWorkerId(workerId, pageable);
    }

    public List<Review> getReviewsByUserId(Long userId) {
        return reviewRepository.findByUserId(userId);
    }

    public Page<Review> getAllReviews(Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        return reviewRepository.findAll(pageable);
    }

    public void deleteReview(Long id) {
        Review review = reviewRepository.findById(id).orElse(null);
        if (review != null) {
            reviewRepository.deleteById(id);
            updateWorkerRating(review.getWorkerId());
        }
    }

    private void updateWorkerRating(Long workerId) {
        Double avgRating = reviewRepository.getAverageRatingByWorkerId(workerId);
        workerRepository.findById(workerId).ifPresent(worker -> {
            if (avgRating != null) {
                worker.setRating(avgRating);
            }
            workerRepository.save(worker);
        });
    }

    public Double getAverageRating(Long workerId) {
        return reviewRepository.getAverageRatingByWorkerId(workerId);
    }

    public List<Review> getAllReviews() {
        return reviewRepository.findAll();
    }

    public Page<Review> searchReviews(String keyword, Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        // 使用内存过滤代替数据库查询
        List<Review> allReviews = reviewRepository.findAll();
        List<Review> filtered = allReviews.stream()
            .filter(r -> (r.getContent() != null && r.getContent().contains(keyword)))
            .toList();
        
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<Review> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();
        
        return new org.springframework.data.domain.PageImpl<>(pageContent, pageable, filtered.size());
    }

    public void updateReviewStatus(Long id, Integer status) {
        Optional<Review> review = reviewRepository.findById(id);
        if (review.isPresent()) {
            Review updatedReview = review.get();
            updatedReview.setStatus(status);
            reviewRepository.save(updatedReview);
        }
    }
}
