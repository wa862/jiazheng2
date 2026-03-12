package com.jiazheng.common;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 系统设置内存存储，供管理端保存、前台首页读取（如热门家政人员数量、标题等）
 */
public final class SettingsStore {

    private static final Map<String, Object> STORE = new ConcurrentHashMap<>();

    private static Map<String, Object> defaultMap() {
        Map<String, Object> m = new HashMap<>();
        m.put("siteName", "家政服务平台");
        m.put("siteLogo", "");
        m.put("siteDescription", "专业家政服务，让生活更美好");
        m.put("contactEmail", "service@jiazheng.com");
        m.put("contactPhone", "400-123-4567");
        m.put("enableRegistration", true);
        m.put("enableReview", true);
        m.put("enableFavorite", true);
        m.put("enableRecommendation", true);
        m.put("minBookingHours", 2);
        m.put("maxBookingDays", 30);
        m.put("cancelOrderHours", 24);
        m.put("enableOnlinePayment", true);
        m.put("enableCashOnDelivery", true);
        m.put("pageSize", 10);
        m.put("homeRecommendationCount", 4);
        m.put("hotWorkersCount", 4);
        m.put("hotWorkersTitle", "热门家政人员");
        m.put("hotWorkersSubtitle", "评分最高的优质服务");
        return m;
    }

    private static final Map<String, Object> DEFAULTS = defaultMap();

    public static Map<String, Object> getAll() {
        Map<String, Object> out = new HashMap<>(DEFAULTS);
        out.putAll(STORE);
        return out;
    }

    public static void putAll(Map<String, Object> settings) {
        if (settings != null && !settings.isEmpty()) {
            STORE.putAll(settings);
        }
    }

    public static Map<String, Object> getHomeConfig() {
        Map<String, Object> all = getAll();
        Map<String, Object> home = new HashMap<>();
        home.put("homeRecommendationCount", all.get("homeRecommendationCount"));
        home.put("hotWorkersCount", all.get("hotWorkersCount"));
        home.put("hotWorkersTitle", all.get("hotWorkersTitle"));
        home.put("hotWorkersSubtitle", all.get("hotWorkersSubtitle"));
        return home;
    }
}
