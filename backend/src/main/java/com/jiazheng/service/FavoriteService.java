package com.jiazheng.service;

import com.jiazheng.entity.Favorite;
import com.jiazheng.entity.Worker;
import com.jiazheng.mapper.FavoriteRepository;
import com.jiazheng.mapper.WorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FavoriteService {

    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private WorkerRepository workerRepository;

    public Favorite addFavorite(Long userId, Long workerId) {
        // 检查是否已收藏
        if (favoriteRepository.existsByUserIdAndWorkerId(userId, workerId)) {
            throw new RuntimeException("已收藏该家政人员");
        }

        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setWorkerId(workerId);
        return favoriteRepository.save(favorite);
    }

    public void removeFavorite(Long userId, Long workerId) {
        favoriteRepository.deleteByUserIdAndWorkerId(userId, workerId);
    }

    public List<Worker> getUserFavorites(Long userId) {
        List<Favorite> favorites = favoriteRepository.findByUserId(userId);
        return favorites.stream()
                .map(f -> workerRepository.findById(f.getWorkerId()).orElse(null))
                .filter(w -> w != null)
                .collect(Collectors.toList());
    }

    public boolean isFavorite(Long userId, Long workerId) {
        return favoriteRepository.existsByUserIdAndWorkerId(userId, workerId);
    }

    public List<Long> getFavoriteWorkerIds(Long userId) {
        return favoriteRepository.findByUserId(userId)
                .stream()
                .map(Favorite::getWorkerId)
                .collect(Collectors.toList());
    }
}
