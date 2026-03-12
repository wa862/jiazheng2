package com.jiazheng.mapper;

import com.jiazheng.entity.Worker;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkerRepository extends JpaRepository<Worker, Long> {

    List<Worker> findByStatus(String status);

    @Query("SELECT w FROM Worker w WHERE w.status = 'active' ORDER BY w.rating DESC")
    List<Worker> findTopRatedWorkers(Pageable pageable);

    Page<Worker> findByCategoryIdAndStatus(Integer categoryId, String status, Pageable pageable);

    Page<Worker> findByStatus(String status, Pageable pageable);

    /** 按分类 + 状态 in 查询，兼容 active / available */
    @Query("SELECT w FROM Worker w WHERE w.categoryId = :categoryId AND w.status IN :statuses")
    Page<Worker> findByCategoryIdAndStatusIn(@Param("categoryId") Integer categoryId, @Param("statuses") List<String> statuses, Pageable pageable);

    @Query("SELECT w FROM Worker w WHERE w.status IN :statuses")
    Page<Worker> findByStatusIn(@Param("statuses") List<String> statuses, Pageable pageable);

    java.util.Optional<Worker> findByPhone(String phone);
}
