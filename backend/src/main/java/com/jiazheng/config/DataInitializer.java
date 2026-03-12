package com.jiazheng.config;

import com.jiazheng.entity.User;
import com.jiazheng.mapper.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setPhone("13800000000");
            admin.setEmail("admin@jiazheng.com");
            // 默认创建一个超级管理员账号，作为最高权限入口
            admin.setRole("superadmin");
            admin.setStatus("active");
            userRepository.save(admin);
            System.out.println("默认超级管理员账号已创建：用户名=admin，密码=admin123");
        }
    }
}
