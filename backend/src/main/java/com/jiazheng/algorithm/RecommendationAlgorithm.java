package com.jiazheng.algorithm;

import com.jiazheng.entity.Worker;
import com.jiazheng.entity.Order;
import com.jiazheng.entity.Review;
import java.util.List;

public interface RecommendationAlgorithm {
    List<Worker> recommendWorkers(Long userId, Integer limit);
    Double calculateMatchScore(Worker worker, Order order);
    Double predictSatisfaction(Long userId, Long workerId, String serviceType);
}