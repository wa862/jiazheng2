package com.jiazheng.mapper;

import com.jiazheng.entity.WorkerCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkerCategoryRepository extends JpaRepository<WorkerCategory, Long> {
    List<WorkerCategory> findByWorkerId(Long workerId);
}
