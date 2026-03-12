package com.jiazheng.mapper;

import com.jiazheng.entity.AlgorithmConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AlgorithmConfigRepository extends JpaRepository<AlgorithmConfig, Long> {
    Optional<AlgorithmConfig> findByConfigKey(String configKey);
}
