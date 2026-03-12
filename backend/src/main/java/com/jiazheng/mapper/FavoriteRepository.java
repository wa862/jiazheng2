package com.jiazheng.mapper;

import com.jiazheng.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    List<Favorite> findByUserId(Long userId);
    
    Optional<Favorite> findByUserIdAndWorkerId(Long userId, Long workerId);
    
    boolean existsByUserIdAndWorkerId(Long userId, Long workerId);
    
    void deleteByUserIdAndWorkerId(Long userId, Long workerId);
}
