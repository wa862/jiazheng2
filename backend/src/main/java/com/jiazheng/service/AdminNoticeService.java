package com.jiazheng.service;

import com.jiazheng.entity.AdminNoticeRead;
import com.jiazheng.mapper.AdminNoticeReadRepository;
import com.jiazheng.mapper.FeedbackRepository;
import com.jiazheng.mapper.WorkerApplicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdminNoticeService {

    private static final String ID_PENDING_APPLICATIONS = "pending_applications";
    private static final String ID_PENDING_FEEDBACK = "pending_feedback";
    private static final String ID_SYSTEM_REPORT = "system_report";
    private static final String ID_ORDER_DISPUTE = "order_dispute";

    @Autowired
    private WorkerApplicationRepository workerApplicationRepository;
    @Autowired
    private FeedbackRepository feedbackRepository;
    @Autowired
    private AdminNoticeReadRepository adminNoticeReadRepository;

    /**
     * 动态生成通知列表：根据入驻申请、用户反馈等实时数据 + 已读状态
     */
    public List<Map<String, Object>> getNotices() {
        List<Map<String, Object>> list = new ArrayList<>();
        Set<String> readIds = adminNoticeReadRepository.findByNoticeIdIn(Arrays.asList(
            ID_PENDING_APPLICATIONS, ID_PENDING_FEEDBACK, ID_SYSTEM_REPORT, ID_ORDER_DISPUTE
        )).stream().map(AdminNoticeRead::getNoticeId).collect(Collectors.toSet());

        long pendingApps = workerApplicationRepository.findByStatus("pending").size();
        if (pendingApps > 0) {
            list.add(noticeItem(ID_PENDING_APPLICATIONS, "入驻申请待审核", relativeTime(LocalDateTime.now().minusMinutes(5)), readIds.contains(ID_PENDING_APPLICATIONS)));
        }

        long pendingFeedback = feedbackRepository.findByStatus("pending").size();
        if (pendingFeedback > 0) {
            list.add(noticeItem(ID_PENDING_FEEDBACK, "用户反馈待处理", relativeTime(LocalDateTime.now().minusMinutes(10)), readIds.contains(ID_PENDING_FEEDBACK)));
        }

        list.add(noticeItem(ID_SYSTEM_REPORT, "今日数据报表已生成", relativeTime(LocalDateTime.now().minusHours(2)), readIds.contains(ID_SYSTEM_REPORT)));
        list.add(noticeItem(ID_ORDER_DISPUTE, "订单纠纷需要处理", relativeTime(LocalDateTime.now().minusMinutes(15)), readIds.contains(ID_ORDER_DISPUTE)));

        list.sort((a, b) -> {
            boolean aRead = Boolean.TRUE.equals(a.get("read"));
            boolean bRead = Boolean.TRUE.equals(b.get("read"));
            if (aRead != bRead) return aRead ? 1 : -1;
            return 0;
        });
        return list;
    }

    private Map<String, Object> noticeItem(String id, String title, String time, boolean read) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", id);
        m.put("title", title);
        m.put("time", time);
        m.put("read", read);
        return m;
    }

    private String relativeTime(LocalDateTime time) {
        long minutes = ChronoUnit.MINUTES.between(time, LocalDateTime.now());
        if (minutes < 1) return "刚刚";
        if (minutes < 60) return minutes + "分钟前";
        long hours = ChronoUnit.HOURS.between(time, LocalDateTime.now());
        if (hours < 24) return hours + "小时前";
        long days = ChronoUnit.DAYS.between(time, LocalDateTime.now());
        return days + "天前";
    }

    public void markRead(String noticeId) {
        if (adminNoticeReadRepository.existsByNoticeId(noticeId)) return;
        AdminNoticeRead r = new AdminNoticeRead();
        r.setNoticeId(noticeId);
        r.setReadAt(LocalDateTime.now());
        adminNoticeReadRepository.save(r);
    }

    public void markAllRead() {
        for (String id : Arrays.asList(ID_PENDING_APPLICATIONS, ID_PENDING_FEEDBACK, ID_SYSTEM_REPORT, ID_ORDER_DISPUTE)) {
            if (!adminNoticeReadRepository.existsByNoticeId(id)) {
                AdminNoticeRead r = new AdminNoticeRead();
                r.setNoticeId(id);
                r.setReadAt(LocalDateTime.now());
                adminNoticeReadRepository.save(r);
            }
        }
    }
}
