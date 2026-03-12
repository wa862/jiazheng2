package com.jiazheng.mapper;

import com.jiazheng.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByWorkerId(Long workerId);
    List<Review> findByUserId(Long userId);
    Page<Review> findByWorkerId(Long workerId, Pageable pageable);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.workerId = :workerId")
    Double getAverageRatingByWorkerId(@Param("workerId") Long workerId);
    
    @Query("SELECT COUNT(r) FROM Review r WHERE r.workerId = :workerId AND r.rating = :rating")
    Long countReviewsByRating(@Param("workerId") Long workerId, @Param("rating") Integer rating);
}
