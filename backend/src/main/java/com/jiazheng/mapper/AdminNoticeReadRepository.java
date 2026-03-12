package com.jiazheng.mapper;

import com.jiazheng.entity.AdminNoticeRead;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AdminNoticeReadRepository extends JpaRepository<AdminNoticeRead, Long> {
    List<AdminNoticeRead> findByNoticeIdIn(List<String> noticeIds);
    boolean existsByNoticeId(String noticeId);
}
