package com.jiazheng.algorithm.impl;

import com.jiazheng.algorithm.RecommendationAlgorithm;
import com.jiazheng.entity.Worker;
import com.jiazheng.entity.Order;
import com.jiazheng.entity.Review;
import com.jiazheng.mapper.WorkerRepository;
import com.jiazheng.mapper.OrderRepository;
import com.jiazheng.mapper.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
public class CollaborativeFilteringAlgorithm implements RecommendationAlgorithm {

    @Autowired
    private WorkerRepository workerRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    private Double ratingWeight = 0.4;
    private Double distanceWeight = 0.2;
    private Double experienceWeight = 0.25;
    private Double priceWeight = 0.15;

    @Override
    public List<Worker> recommendWorkers(Long userId, Integer limit) {
        List<Order> userOrders = orderRepository.findByUserId(userId);
        if (userOrders.isEmpty()) {
            return workerRepository.findTopRatedWorkers(PageRequest.of(0, limit));
        }

        Set<Long> workerIds = userOrders.stream()
                .map(Order::getWorkerId)
                .collect(Collectors.toSet());

        List<Worker> allWorkers = workerRepository.findAll().stream()
                .filter(w -> !workerIds.contains(w.getId()) && "已上架".equals(w.getStatus()))
                .collect(Collectors.toList());

        Map<Long, Double> similarityScores = new HashMap<>();
        for (Worker worker : allWorkers) {
            double score = calculateSimilarity(userId, worker);
            similarityScores.put(worker.getId(), score);
        }

        return allWorkers.stream()
                .sorted((w1, w2) -> similarityScores.get(w2.getId()).compareTo(similarityScores.get(w1.getId())))
                .limit(limit)
                .collect(Collectors.toList());
    }

    private double calculateSimilarity(Long userId, Worker worker) {
        List<Order> userOrders = orderRepository.findByUserId(userId);
        List<Review> workerReviews = reviewRepository.findByWorkerId(worker.getId());

        double avgUserRating = userOrders.stream()
                .mapToDouble(o -> {
                    List<Review> reviews = reviewRepository.findByWorkerId(o.getWorkerId());
                    return reviews.stream().mapToDouble(Review::getRating).average().orElse(0);
                })
                .average()
                .orElse(0);

        double avgWorkerRating = workerReviews.stream()
                .mapToDouble(Review::getRating)
                .average()
                .orElse(worker.getRating());

        double dotProduct = avgUserRating * avgWorkerRating;
        double magnitudeUser = Math.sqrt(avgUserRating * avgUserRating);
        double magnitudeWorker = Math.sqrt(avgWorkerRating * avgWorkerRating);

        double cosineSimilarity = (magnitudeUser * magnitudeWorker) > 0 
                ? dotProduct / (magnitudeUser * magnitudeWorker) 
                : 0;

        return cosineSimilarity;
    }

    @Override
    public Double calculateMatchScore(Worker worker, Order order) {
        double ratingScore = worker.getRating() / 5.0;
        double experienceScore = Math.min(worker.getExperience() / 10.0, 1.0);
        double priceScore = calculatePriceMatch(worker.getPrice(), order.getTotalAmount().doubleValue() / (order.getDuration() != null ? order.getDuration() : 1));
        double distanceScore = 1.0;

        return ratingWeight * ratingScore +
               distanceWeight * distanceScore +
               experienceWeight * experienceScore +
               priceWeight * priceScore;
    }

    private double calculatePriceMatch(Double workerPrice, Double userPrice) {
        double diff = Math.abs(workerPrice - userPrice);
        double maxDiff = Math.max(workerPrice, userPrice);
        return maxDiff > 0 ? 1 - (diff / maxDiff) : 1.0;
    }

    @Override
    public Double predictSatisfaction(Long userId, Long workerId, String serviceType) {
        Worker worker = workerRepository.findById(workerId).orElse(null);
        if (worker == null) return 0.0;

        List<Review> reviews = reviewRepository.findByWorkerId(workerId);
        if (reviews.isEmpty()) return worker.getRating() * 20.0;

        double avgRating = reviews.stream()
                .mapToDouble(Review::getRating)
                .average()
                .orElse(worker.getRating());

        double experienceFactor = Math.min(worker.getExperience() / 5.0, 1.2);

        double predictedScore = avgRating * 20.0 * experienceFactor;
        return Math.min(predictedScore, 100.0);
    }

    public void setWeights(Double ratingWeight, Double distanceWeight, Double experienceWeight, Double priceWeight) {
        this.ratingWeight = ratingWeight;
        this.distanceWeight = distanceWeight;
        this.experienceWeight = experienceWeight;
        this.priceWeight = priceWeight;
    }
}