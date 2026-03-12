package com.jiazheng.mapper;

import com.jiazheng.entity.WorkerApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkerApplicationRepository extends JpaRepository<WorkerApplication, Long> {
    List<WorkerApplication> findByStatus(String status);
    List<WorkerApplication> findByServiceType(String serviceType);
    List<WorkerApplication> findByPhoneContaining(String phone);
    List<WorkerApplication> findByNameContaining(String name);
}
