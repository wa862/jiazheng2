package com.jiazheng.controller;

import com.jiazheng.common.Result;
import com.jiazheng.common.SettingsStore;
import com.jiazheng.entity.Worker;
import com.jiazheng.service.WorkerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/workers")
@CrossOrigin(origins = "*")
public class WorkerController {

    @Autowired
    private WorkerService workerService;

    @GetMapping
    public Result<Map<String, Object>> getWorkers(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Integer categoryId,
            @RequestParam(required = false) String priceSort,
            @RequestParam(required = false) String ratingSort,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice) {
        Page<Worker> workers = workerService.getWorkers(page, pageSize, categoryId, priceSort, ratingSort, minPrice, maxPrice);
        Map<String, Object> response = new HashMap<>();
        response.put("list", workers.getContent());
        response.put("total", workers.getTotalElements());
        return Result.success(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getWorkerById(@PathVariable Long id) {
        Optional<Worker> worker = workerService.getWorkerById(id);
        if (worker.isPresent()) {
            return ResponseEntity.ok(worker.get());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/search")
    public ResponseEntity<?> searchWorkers(@RequestParam String keyword) {
        List<Worker> workers = workerService.searchWorkers(keyword);
        return ResponseEntity.ok(workers);
    }

    @GetMapping("/recommended/{userId}")
    public ResponseEntity<?> getRecommendedWorkers(@PathVariable Long userId) {
        List<Worker> workers = workerService.getRecommendedWorkers(userId);
        return ResponseEntity.ok(workers);
    }

    @GetMapping("/top-rated")
    public ResponseEntity<?> getTopRatedWorkers(@RequestParam(defaultValue = "10") Integer limit) {
        List<Worker> workers = workerService.getTopRatedWorkers(limit);
        return ResponseEntity.ok(workers);
    }

    @PostMapping
    public ResponseEntity<?> createWorker(@RequestBody Worker worker) {
        Worker createdWorker = workerService.createWorker(worker);
        return ResponseEntity.ok(createdWorker);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateWorker(@PathVariable Long id, @RequestBody Worker worker) {
        worker.setId(id);
        Worker updatedWorker = workerService.updateWorker(worker);
        return ResponseEntity.ok(updatedWorker);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteWorker(@PathVariable Long id) {
        workerService.deleteWorker(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "家政人员已删除"));
    }

    @PutMapping("/{id}/approve")
    public ResponseEntity<?> approveWorker(@PathVariable Long id) {
        workerService.approveWorker(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "家政人员已审核通过"));
    }

    @PutMapping("/{id}/reject")
    public ResponseEntity<?> rejectWorker(@PathVariable Long id) {
        workerService.rejectWorker(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "家政人员已拒绝"));
    }

    @PutMapping("/{id}/offline")
    public ResponseEntity<?> offlineWorker(@PathVariable Long id) {
        workerService.offlineWorker(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "家政人员已下架"));
    }

    @PutMapping("/{id}/online")
    public ResponseEntity<?> onlineWorker(@PathVariable Long id) {
        workerService.onlineWorker(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "家政人员已上架"));
    }

    @GetMapping("/{id}/services")
    public ResponseEntity<?> getWorkerServices(@PathVariable Long id) {
        var services = workerService.getWorkerServiceCategories(id);
        return ResponseEntity.ok(services);
    }

    /** 首页展示配置（热门家政人员数量、标题等，无需登录） */
    @GetMapping("/home-config")
    public Result<Map<String, Object>> getHomeConfig() {
        return Result.success(SettingsStore.getHomeConfig());
    }

    @GetMapping("/categories")
    public ResponseEntity<?> getCategories() {
        // 返回服务分类数据
        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("message", "success");
        
        List<Map<String, Object>> categories = new ArrayList<>();
        
        Map<String, Object> category1 = new HashMap<>();
        category1.put("id", 1);
        category1.put("name", "保洁服务");
        category1.put("description", "家庭保洁、深度清洁");
        category1.put("icon", "Brush");
        category1.put("color", "#4CAF50");
        category1.put("sortOrder", 1);
        category1.put("status", 1);
        categories.add(category1);
        
        Map<String, Object> category2 = new HashMap<>();
        category2.put("id", 2);
        category2.put("name", "月嫂服务");
        category2.put("description", "专业月嫂、母婴护理");
        category2.put("icon", "User");
        category2.put("color", "#2196F3");
        category2.put("sortOrder", 2);
        category2.put("status", 1);
        categories.add(category2);
        
        Map<String, Object> category3 = new HashMap<>();
        category3.put("id", 3);
        category3.put("name", "护理服务");
        category3.put("description", "老人陪护、康复护理");
        category3.put("icon", "Monitor");
        category3.put("color", "#FF9800");
        category3.put("sortOrder", 3);
        category3.put("status", 1);
        categories.add(category3);
        
        Map<String, Object> category4 = new HashMap<>();
        category4.put("id", 4);
        category4.put("name", "钟点工");
        category4.put("description", "临时帮工、日常杂务");
        category4.put("icon", "Tools");
        category4.put("color", "#9C27B0");
        category4.put("sortOrder", 4);
        category4.put("status", 1);
        categories.add(category4);
        
        Map<String, Object> category5 = new HashMap<>();
        category5.put("id", 5);
        category5.put("name", "育儿嫂");
        category5.put("description", "婴幼儿照护、早教");
        category5.put("icon", "Baby");
        category5.put("color", "#E91E63");
        category5.put("sortOrder", 5);
        category5.put("status", 1);
        categories.add(category5);
        
        Map<String, Object> category6 = new HashMap<>();
        category6.put("id", 6);
        category6.put("name", "家电清洗");
        category6.put("description", "空调、油烟机清洗");
        category6.put("icon", "Dish");
        category6.put("color", "#00BCD4");
        category6.put("sortOrder", 6);
        category6.put("status", 1);
        categories.add(category6);
        
        response.put("data", categories);
        return ResponseEntity.ok(response);
    }
}
