package com.jiazheng.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jiazheng.entity.Worker;
import com.jiazheng.entity.WorkerApplication;
import com.jiazheng.mapper.WorkerApplicationRepository;
import com.jiazheng.mapper.WorkerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WorkerApplicationService {

    @Autowired
    private WorkerApplicationRepository applicationRepository;

    @Autowired
    private WorkerRepository workerRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public Page<WorkerApplication> getApplications(Integer page, Integer pageSize, String keyword, String status, String serviceType) {
        Pageable pageable = PageRequest.of(page, pageSize);
        List<WorkerApplication> allApplications = applicationRepository.findAll();
        
        // 过滤
        List<WorkerApplication> filtered = allApplications.stream()
            .filter(a -> {
                // 关键词过滤
                if (keyword != null && !keyword.isEmpty()) {
                    boolean matchKeyword = (a.getName() != null && a.getName().contains(keyword)) ||
                                          (a.getPhone() != null && a.getPhone().contains(keyword));
                    if (!matchKeyword) return false;
                }
                // 状态过滤
                if (status != null && !status.isEmpty()) {
                    if (!status.equals(a.getStatus())) return false;
                }
                // 服务类型过滤
                if (serviceType != null && !serviceType.isEmpty()) {
                    if (!serviceType.equals(a.getServiceType())) return false;
                }
                return true;
            })
            .sorted((a1, a2) -> {
                // 按申请时间倒序
                if (a1.getApplyTime() == null) return 1;
                if (a2.getApplyTime() == null) return -1;
                return a2.getApplyTime().compareTo(a1.getApplyTime());
            })
            .collect(Collectors.toList());
        
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<WorkerApplication> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();
        
        return new PageImpl<>(pageContent, pageable, filtered.size());
    }

    public WorkerApplication getApplicationById(Long id) {
        Optional<WorkerApplication> application = applicationRepository.findById(id);
        return application.orElse(null);
    }

    public Map<String, Object> getApplicationStats() {
        List<WorkerApplication> allApplications = applicationRepository.findAll();
        
        long total = allApplications.size();
        long pending = allApplications.stream().filter(a -> "pending".equals(a.getStatus())).count();
        long approved = allApplications.stream().filter(a -> "approved".equals(a.getStatus())).count();
        long rejected = allApplications.stream().filter(a -> "rejected".equals(a.getStatus())).count();
        
        return Map.of(
            "total", total,
            "pending", pending,
            "approved", approved,
            "rejected", rejected
        );
    }

    @Transactional
    public void approveApplication(Long id, String reviewer) throws Exception {
        Optional<WorkerApplication> appOpt = applicationRepository.findById(id);
        if (appOpt.isPresent()) {
            WorkerApplication application = appOpt.get();
            
            // 更新申请状态
            application.setStatus("approved");
            application.setReviewTime(LocalDateTime.now());
            application.setReviewer(reviewer);
            applicationRepository.save(application);
            
            // 检查手机号是否已存在
            Optional<Worker> existingWorker = workerRepository.findByPhone(application.getPhone());
            if (existingWorker.isPresent()) {
                throw new Exception("手机号已存在，无法创建家政人员");
            }
            
            // 创建家政人员记录
            Worker worker = new Worker();
            worker.setName(application.getName());
            worker.setGender(application.getGender());
            worker.setPhone(application.getPhone());
            worker.setAvatar(application.getAvatar());
            worker.setExperience(application.getExperience());
            worker.setPrice(application.getExpectedSalary());
            worker.setStatus("active");
            worker.setDescription(application.getIntroduction());
            
            workerRepository.save(worker);
        }
    }

    public void rejectApplication(Long id, String reviewer, String reason) {
        Optional<WorkerApplication> appOpt = applicationRepository.findById(id);
        if (appOpt.isPresent()) {
            WorkerApplication application = appOpt.get();
            application.setStatus("rejected");
            application.setReviewTime(LocalDateTime.now());
            application.setReviewer(reviewer);
            application.setRejectReason(reason);
            applicationRepository.save(application);
        }
    }

    public void deleteApplication(Long id) {
        applicationRepository.deleteById(id);
    }

    public WorkerApplication createApplication(WorkerApplication application) {
        application.setStatus("pending");
        return applicationRepository.save(application);
    }
}
