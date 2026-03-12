package com.jiazheng.mapper;

import com.jiazheng.entity.ServiceCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServiceCategoryRepository extends JpaRepository<ServiceCategory, Long> {
    List<ServiceCategory> findByStatusOrderBySortOrderAsc(Integer status);
    List<ServiceCategory> findAllByOrderBySortOrderAsc();
}
