package com.jiazheng.service;

import com.jiazheng.entity.User;
import com.jiazheng.mapper.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User register(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("手机号已存在");
        }
        user.setRole("user");
        user.setStatus("active");
        return userRepository.save(user);
    }

    public Optional<User> login(String username, String password) {
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isPresent() && user.get().getPassword().equals(password)) {
            return user;
        }
        return Optional.empty();
    }

    public Optional<User> loginByPhone(String phone, String password) {
        Optional<User> user = userRepository.findByPhone(phone);
        if (user.isPresent() && user.get().getPassword().equals(password)) {
            return user;
        }
        return Optional.empty();
    }

    public Optional<User> adminLogin(String username, String password) {
        Optional<User> user = userRepository.findByUsername(username);
        if (user.isPresent() && user.get().getPassword().equals(password) && "admin".equals(user.get().getRole())) {
            return user;
        }
        return Optional.empty();
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    /**
     * 后台用户列表查询，支持关键字、角色、状态多条件过滤
     */
    public Page<User> getUsers(Integer page, Integer pageSize, String keyword, String role, String status) {
        Pageable pageable = PageRequest.of(page, pageSize);

        List<User> allUsers = userRepository.findAll();

        List<User> filtered = allUsers.stream()
            .filter(u -> {
                // 关键字：用户名 / 邮箱 / 手机号 / 姓名 模糊匹配
                if (keyword != null && !keyword.isEmpty()) {
                    boolean matchUsername = u.getUsername() != null && u.getUsername().contains(keyword);
                    boolean matchEmail = u.getEmail() != null && u.getEmail().contains(keyword);
                    boolean matchPhone = u.getPhone() != null && u.getPhone().contains(keyword);
                    boolean matchName = u.getName() != null && u.getName().contains(keyword);
                    if (!(matchUsername || matchEmail || matchPhone || matchName)) {
                        return false;
                    }
                }

                // 角色筛选
                if (role != null && !role.isEmpty()) {
                    if (u.getRole() == null || !role.equalsIgnoreCase(u.getRole())) {
                        return false;
                    }
                }

                // 状态筛选：正常 / 禁用 -> active / disabled
                if (status != null && !status.isEmpty()) {
                    if (u.getStatus() == null || !status.equalsIgnoreCase(u.getStatus())) {
                        return false;
                    }
                }

                return true;
            })
            .toList();

        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), filtered.size());
        List<User> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();

        return new org.springframework.data.domain.PageImpl<>(pageContent, pageable, filtered.size());
    }

    public User updateUser(User user) {
        Optional<User> existingUser = userRepository.findById(user.getId());
        if (existingUser.isPresent()) {
            User updatedUser = existingUser.get();
            // 只更新非空字段
            if (user.getUsername() != null) {
                updatedUser.setUsername(user.getUsername());
            }
            if (user.getEmail() != null) {
                updatedUser.setEmail(user.getEmail());
            }
            if (user.getPhone() != null) {
                updatedUser.setPhone(user.getPhone());
            }
            if (user.getName() != null) {
                updatedUser.setName(user.getName());
            }
            if (user.getAddress() != null) {
                updatedUser.setAddress(user.getAddress());
            }
            if (user.getAvatar() != null) {
                updatedUser.setAvatar(user.getAvatar());
            }
            if (user.getStatus() != null) {
                updatedUser.setStatus(user.getStatus());
            }
            if (user.getRole() != null) {
                updatedUser.setRole(user.getRole());
            }
            return userRepository.save(updatedUser);
        }
        throw new RuntimeException("用户不存在");
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    public void freezeUser(Long id) {
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            user.get().setStatus("inactive");
            userRepository.save(user.get());
        }
    }

    public void unfreezeUser(Long id) {
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            user.get().setStatus("active");
            userRepository.save(user.get());
        }
    }

    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        if (userRepository.existsByPhone(user.getPhone())) {
            throw new RuntimeException("手机号已存在");
        }
        // 如果未指定角色，则默认普通用户；否则使用前端/调用方传入的角色
        if (user.getRole() == null || user.getRole().isBlank()) {
            user.setRole("user");
        }
        if (user.getStatus() == null) {
            user.setStatus("active");
        }
        return userRepository.save(user);
    }

    public void updateUserStatus(Long id, String status) {
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            User updatedUser = user.get();
            updatedUser.setStatus(status);
            userRepository.save(updatedUser);
        } else {
            throw new RuntimeException("用户不存在");
        }
    }

    /** 全部启用：将所有用户状态设为 active */
    public int enableAllUsers() {
        List<User> all = userRepository.findAll();
        for (User u : all) {
            u.setStatus("active");
            userRepository.save(u);
        }
        return all.size();
    }
}
