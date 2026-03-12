package com.jiazheng.service;

import com.jiazheng.algorithm.RecommendationAlgorithm;
import com.jiazheng.entity.ServiceCategory;
import com.jiazheng.entity.Worker;
import com.jiazheng.entity.WorkerCategory;
import com.jiazheng.mapper.ServiceCategoryRepository;
import com.jiazheng.mapper.WorkerCategoryRepository;
import com.jiazheng.mapper.WorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WorkerService {

    @Autowired
    private WorkerRepository workerRepository;

    @Autowired
    private WorkerCategoryRepository workerCategoryRepository;

    @Autowired
    private ServiceCategoryRepository serviceCategoryRepository;

    @Autowired
    private RecommendationAlgorithm recommendationAlgorithm;

    public Worker createWorker(Worker worker) {
        worker.setRating(0.0);
        worker.setStatus("pending");
        return workerRepository.save(worker);
    }

    public Optional<Worker> getWorkerById(Long id) {
        return workerRepository.findById(id);
    }

    public List<Worker> getAllWorkers() {
        return workerRepository.findAll();
    }

    public Page<Worker> getWorkers(Integer page, Integer pageSize, Integer categoryId, String priceSort, String ratingSort,
                                   Double minPrice, Double maxPrice) {
        List<String> activeStatuses = List.of("active", "available");
        List<Worker> baseList;
        int fetchSize = 10000;
        if (categoryId != null) {
            Page<Worker> p = workerRepository.findByCategoryIdAndStatusIn(categoryId, activeStatuses, PageRequest.of(0, fetchSize));
            baseList = p.getContent();
        } else {
            Page<Worker> p = workerRepository.findByStatusIn(activeStatuses, PageRequest.of(0, fetchSize));
            baseList = p.getContent();
        }
        java.util.stream.Stream<Worker> stream = baseList.stream();
        if (minPrice != null && minPrice > 0) {
            stream = stream.filter(w -> w.getPrice() != null && w.getPrice() >= minPrice);
        }
        if (maxPrice != null && maxPrice > 0) {
            stream = stream.filter(w -> w.getPrice() != null && w.getPrice() <= maxPrice);
        }
        List<Worker> filtered = stream.toList();
        if ("asc".equals(priceSort)) {
            filtered = filtered.stream().sorted(java.util.Comparator.comparing(Worker::getPrice, java.util.Comparator.nullsLast(Double::compareTo))).toList();
        } else if ("desc".equals(priceSort)) {
            filtered = filtered.stream().sorted(java.util.Comparator.comparing(Worker::getPrice, java.util.Comparator.nullsLast(Double::compareTo)).reversed()).toList();
        } else if ("desc".equals(ratingSort)) {
            filtered = filtered.stream().sorted(java.util.Comparator.comparing(Worker::getRating, java.util.Comparator.nullsLast(Double::compareTo)).reversed()).toList();
        } else if ("asc".equals(ratingSort)) {
            filtered = filtered.stream().sorted(java.util.Comparator.comparing(Worker::getRating, java.util.Comparator.nullsLast(Double::compareTo))).toList();
        }
        int start = (page - 1) * pageSize;
        int end = Math.min(start + pageSize, filtered.size());
        List<Worker> content = start < filtered.size() ? filtered.subList(start, end) : List.of();
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        return new org.springframework.data.domain.PageImpl<>(content, pageable, filtered.size());
    }

    public List<Worker> searchWorkers(String keyword) {
        String k = keyword == null ? "" : keyword.trim();

        // 先加载所有家政人员
        List<Worker> allWorkers = workerRepository.findAll();

        // 加载服务分类；如果数据库里没有数据，则使用一份与前端展示一致的兜底映射
        List<ServiceCategory> categories = serviceCategoryRepository.findAll();
        Map<Integer, String> categoryNameMap = categories.stream()
                .collect(Collectors.toMap(
                        c -> c.getId().intValue(),
                        ServiceCategory::getName,
                        (a, b) -> a
                ));
        if (categoryNameMap.isEmpty()) {
            categoryNameMap.put(1, "保洁服务");
            categoryNameMap.put(2, "月嫂服务");
            categoryNameMap.put(3, "护理服务");
            categoryNameMap.put(4, "钟点工");
            categoryNameMap.put(5, "育儿嫂");
            categoryNameMap.put(6, "家电清洗");
            categoryNameMap.put(7, "管家服务");
        }

        String lowerKey = k.toLowerCase();

        // 如果关键字明显是在搜服务类型（如“保洁”“保洁服务”“月嫂”等），优先按分类过滤
        Integer categoryFromKeyword = null;
        if (!lowerKey.isEmpty()) {
            if (lowerKey.contains("保洁")) {
                categoryFromKeyword = 1;
            } else if (lowerKey.contains("月嫂")) {
                categoryFromKeyword = 2;
            } else if (lowerKey.contains("护理")) {
                categoryFromKeyword = 3;
            } else if (lowerKey.contains("钟点工") || lowerKey.contains("小时工")) {
                categoryFromKeyword = 4;
            } else if (lowerKey.contains("育儿")) {
                categoryFromKeyword = 5;
            } else if (lowerKey.contains("家电") || lowerKey.contains("清洗")) {
                categoryFromKeyword = 6;
            } else if (lowerKey.contains("管家")) {
                categoryFromKeyword = 7;
            }
        }

        // 为了兼容较低版本的编译器，这里使用一个最终变量供 lambda 使用
        final Integer catKey = categoryFromKeyword;

        return allWorkers.stream()
                // 按名称 / 电话 / 服务类型名称 / 描述 / 地址 进行模糊匹配（忽略大小写）
                .filter(w -> {
                    if (lowerKey.isEmpty()) {
                        // 没有关键字时，返回所有家政人员（前端再做价格/分类筛选）
                        return true;
                    }

                    // 如果识别出了具体服务类型关键字，则只保留该分类的家政人员
                    if (catKey != null) {
                        if (w.getCategoryId() == null || !catKey.equals(w.getCategoryId())) {
                            return false;
                        }
                    }

                    String name = Optional.ofNullable(w.getName()).orElse("");
                    String phone = Optional.ofNullable(w.getPhone()).orElse("");
                    String desc = Optional.ofNullable(w.getDescription()).orElse("");
                    String categoryName = "";
                    if (w.getCategoryId() != null) {
                        categoryName = categoryNameMap.getOrDefault(w.getCategoryId(), "");
                    }
                    String combined = (name + phone + desc + categoryName).toLowerCase();
                    return combined.contains(lowerKey);
                })
                .limit(100)
                .toList();
    }

    public List<Worker> getRecommendedWorkers(Long userId) {
        return workerRepository.findAll().stream()
                .sorted((w1, w2) -> Double.compare(w2.getRating(), w1.getRating()))
                .limit(10)
                .toList();
    }

    public Worker updateWorker(Worker worker) {
        Optional<Worker> existingWorker = workerRepository.findById(worker.getId());
        if (existingWorker.isPresent()) {
            Worker updatedWorker = existingWorker.get();
            // 只更新非空字段
            if (worker.getName() != null) {
                updatedWorker.setName(worker.getName());
            }
            if (worker.getPhone() != null) {
                updatedWorker.setPhone(worker.getPhone());
            }
            if (worker.getGender() != null) {
                updatedWorker.setGender(worker.getGender());
            }
            if (worker.getAge() != null) {
                updatedWorker.setAge(worker.getAge());
            }
            if (worker.getExperience() != null) {
                updatedWorker.setExperience(worker.getExperience());
            }
            if (worker.getDescription() != null) {
                updatedWorker.setDescription(worker.getDescription());
            }
            if (worker.getPrice() != null) {
                updatedWorker.setPrice(worker.getPrice());
            }
            if (worker.getStatus() != null) {
                updatedWorker.setStatus(worker.getStatus());
            }
            if (worker.getAvatar() != null) {
                updatedWorker.setAvatar(worker.getAvatar());
            }
            if (worker.getCategoryId() != null) {
                updatedWorker.setCategoryId(worker.getCategoryId());
            }
            return workerRepository.save(updatedWorker);
        }
        throw new RuntimeException("家政人员不存在");
    }

    public void deleteWorker(Long id) {
        workerRepository.deleteById(id);
    }

    public void approveWorker(Long id) {
        Optional<Worker> worker = workerRepository.findById(id);
        if (worker.isPresent()) {
            worker.get().setStatus("active");
            workerRepository.save(worker.get());
        }
    }

    public void rejectWorker(Long id) {
        Optional<Worker> worker = workerRepository.findById(id);
        if (worker.isPresent()) {
            worker.get().setStatus("rejected");
            workerRepository.save(worker.get());
        }
    }

    public void offlineWorker(Long id) {
        Optional<Worker> worker = workerRepository.findById(id);
        if (worker.isPresent()) {
            worker.get().setStatus("inactive");
            workerRepository.save(worker.get());
        }
    }

    public void onlineWorker(Long id) {
        Optional<Worker> worker = workerRepository.findById(id);
        if (worker.isPresent()) {
            worker.get().setStatus("active");
            workerRepository.save(worker.get());
        }
    }

    public List<Worker> getTopRatedWorkers(Integer limit) {
        return workerRepository.findTopRatedWorkers(PageRequest.of(0, limit));
    }

    public List<ServiceCategory> getWorkerServiceCategories(Long workerId) {
        List<WorkerCategory> workerCategories = workerCategoryRepository.findByWorkerId(workerId);
        List<Long> categoryIds = workerCategories.stream()
                .map(wc -> wc.getCategoryId().longValue())
                .collect(Collectors.toList());
        return serviceCategoryRepository.findAllById(categoryIds);
    }

    public Optional<ServiceCategory> getServiceCategoryById(Long id) {
        return serviceCategoryRepository.findById(id);
    }
}
