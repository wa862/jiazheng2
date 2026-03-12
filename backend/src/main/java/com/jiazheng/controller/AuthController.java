package com.jiazheng.controller;

import com.jiazheng.common.Result;
import com.jiazheng.dto.LoginDTO;
import com.jiazheng.dto.RegisterDTO;
import com.jiazheng.entity.User;
import com.jiazheng.mapper.UserRepository;
import com.jiazheng.utils.JwtUtil;
import com.jiazheng.vo.LoginVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    @Transactional
    public Result<String> register(@RequestBody RegisterDTO dto) {
        logger.info("收到注册请求: username={}, phone={}, name={}", dto.getUsername(), dto.getPhone(), dto.getName());
        
        // 1. 校验参数
        if (dto.getUsername() == null || dto.getUsername().trim().isEmpty()) {
            return Result.error("用户名不能为空");
        }
        if (dto.getPassword() == null || dto.getPassword().trim().isEmpty()) {
            return Result.error("密码不能为空");
        }
        if (dto.getPassword().length() < 6) {
            return Result.error("密码长度不能少于6位");
        }

        // 2. 判断用户名是否存在
        Optional<User> existingUser = userRepository.findByUsername(dto.getUsername());
        if (existingUser.isPresent()) {
            logger.warn("用户名已存在: {}", dto.getUsername());
            return Result.error("用户名已存在");
        }

        // 3. 判断手机号是否已注册
        if (dto.getPhone() != null && !dto.getPhone().trim().isEmpty()) {
            Optional<User> existingPhone = userRepository.findByPhone(dto.getPhone());
            if (existingPhone.isPresent()) {
                logger.warn("手机号已注册: {}", dto.getPhone());
                return Result.error("手机号已注册");
            }
        }

        // 4. 加密密码
        String encodedPassword = passwordEncoder.encode(dto.getPassword());

        // 5. 创建新用户
        User newUser = new User();
        newUser.setUsername(dto.getUsername());
        newUser.setPassword(encodedPassword);
        newUser.setPhone(dto.getPhone() != null && !dto.getPhone().trim().isEmpty() ? dto.getPhone() : "1" + System.currentTimeMillis());
        newUser.setName(dto.getName() != null ? dto.getName() : dto.getUsername());
        newUser.setRole("user");
        newUser.setStatus("active");

        // 6. 保存用户
        User savedUser = userRepository.save(newUser);
        logger.info("用户注册成功: id={}, username={}", savedUser.getId(), savedUser.getUsername());

        return Result.success("注册成功", null);
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<LoginVO> login(@RequestBody LoginDTO dto) {
        // 1. 校验参数
        if (dto.getUsername() == null || dto.getUsername().trim().isEmpty()) {
            return Result.error("用户名不能为空");
        }
        if (dto.getPassword() == null || dto.getPassword().trim().isEmpty()) {
            return Result.error("密码不能为空");
        }

        // 2. 查询用户
        Optional<User> userOptional = userRepository.findByUsername(dto.getUsername());
        if (userOptional.isEmpty()) {
            return Result.error("用户名或密码错误");
        }

        User user = userOptional.get();

        // 3. 校验密码
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            return Result.error("用户名或密码错误");
        }

        // 4. 账号状态校验（当前版本放宽，只拦截被明确标记为禁用的账号）
        if ("disabled".equalsIgnoreCase(user.getStatus())) {
            return Result.error("账号已被禁用，请联系管理员");
        }

        // 5. 生成JWT token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());

        // 6. 组装返回数据
        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setUserId(user.getId());
        loginVO.setUsername(user.getUsername());
        loginVO.setName(user.getName());
        loginVO.setRole(user.getRole());
        loginVO.setAvatar(user.getAvatar());

        return Result.success("登录成功", loginVO);
    }

    /**
     * 获取当前登录用户信息
     */
    @GetMapping("/info")
    public Result<LoginVO> getUserInfo(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Result.error(401, "未登录");
        }

        String token = authHeader.substring(7);
        if (!jwtUtil.validateToken(token)) {
            return Result.error(401, "token无效或已过期");
        }

        Long userId = jwtUtil.getUserIdFromToken(token);
        Optional<User> userOptional = userRepository.findById(userId);
        
        if (userOptional.isEmpty()) {
            return Result.error(401, "用户不存在");
        }

        User user = userOptional.get();
        LoginVO loginVO = new LoginVO();
        loginVO.setUserId(user.getId());
        loginVO.setUsername(user.getUsername() != null ? user.getUsername() : "");
        loginVO.setName(user.getName() != null ? user.getName() : "");
        loginVO.setPhone(user.getPhone() != null ? user.getPhone() : "");
        loginVO.setEmail(user.getEmail() != null ? user.getEmail() : "");
        loginVO.setAddress(user.getAddress() != null ? user.getAddress() : "");
        loginVO.setRole(user.getRole() != null ? user.getRole() : "user");
        loginVO.setAvatar(user.getAvatar() != null ? user.getAvatar() : "");

        return Result.success(loginVO);
    }

    /**
     * 当前用户更新个人信息（姓名、手机、邮箱、地址等，不包含密码）
     */
    @PutMapping("/info")
    @Transactional
    public Result<LoginVO> updateUserInfo(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, String> body) {
        return doUpdateUserInfo(authHeader, body);
    }

    /**
     * 更新个人信息（POST 别名，避免部分代理/环境对 PUT 返回 405）
     */
    @PostMapping("/info/update")
    @Transactional
    public Result<LoginVO> updateUserInfoPost(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, String> body) {
        return doUpdateUserInfo(authHeader, body);
    }

    private Result<LoginVO> doUpdateUserInfo(String authHeader, Map<String, String> body) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Result.error(401, "未登录");
        }
        String token = authHeader.substring(7);
        if (!jwtUtil.validateToken(token)) {
            return Result.error(401, "token无效或已过期");
        }
        Long userId = jwtUtil.getUserIdFromToken(token);
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            return Result.error("用户不存在");
        }
        User user = userOptional.get();
        if (body != null) {
            if (body.containsKey("name")) user.setName(body.get("name"));
            if (body.containsKey("phone")) user.setPhone(body.get("phone"));
            if (body.containsKey("email")) user.setEmail(body.get("email"));
            if (body.containsKey("address")) user.setAddress(body.get("address"));
            if (body.containsKey("avatar")) user.setAvatar(body.get("avatar"));
        }
        userRepository.save(user);
        LoginVO loginVO = new LoginVO();
        loginVO.setUserId(user.getId());
        loginVO.setUsername(user.getUsername());
        loginVO.setName(user.getName());
        loginVO.setPhone(user.getPhone());
        loginVO.setEmail(user.getEmail());
        loginVO.setAddress(user.getAddress());
        loginVO.setRole(user.getRole());
        loginVO.setAvatar(user.getAvatar());
        return Result.success("保存成功", loginVO);
    }

    /**
     * 管理员登录
     */
    @PostMapping("/admin/login")
    public Result<LoginVO> adminLogin(@RequestBody LoginDTO dto) {
        // 1. 校验参数
        if (dto.getUsername() == null || dto.getUsername().trim().isEmpty()) {
            return Result.error("用户名不能为空");
        }
        if (dto.getPassword() == null || dto.getPassword().trim().isEmpty()) {
            return Result.error("密码不能为空");
        }

        // 2. 查询用户
        Optional<User> userOptional = userRepository.findByUsername(dto.getUsername());
        if (userOptional.isEmpty()) {
            return Result.error("用户名或密码错误");
        }

        User user = userOptional.get();

        // 3. 校验密码
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            return Result.error("用户名或密码错误");
        }

        // 4. 检查账号状态（管理员仅在被明确禁用时禁止登录）
        if ("disabled".equalsIgnoreCase(user.getStatus())) {
            return Result.error("账号已被禁用，请联系超级管理员");
        }

        // 5. 检查是否为管理员角色（普通管理员或超级管理员，兼容 supperadmin 拼写）
        String role = user.getRole() != null ? user.getRole().toLowerCase() : "";
        boolean isAdmin = "admin".equals(role) || "superadmin".equals(role) || "supperadmin".equals(role);
        if (!isAdmin) {
            return Result.error("只有管理员才能登录后台");
        }

        // 6. 生成JWT token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());

        // 7. 组装返回数据
        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setUserId(user.getId());
        loginVO.setUsername(user.getUsername());
        loginVO.setName(user.getName());
        loginVO.setRole(user.getRole());
        loginVO.setAvatar(user.getAvatar());

        return Result.success("登录成功", loginVO);
    }

    /**
     * 修改密码（用户端和管理员端通用：根据当前 token 识别用户，校验原密码后更新为新密码）
     * 支持 POST /api/auth/change-password 与 /api/auth/changePassword 两种路径
     */
    @PostMapping(value = { "/change-password", "/changePassword" })
    @Transactional
    public Result<String> changePassword(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, String> body) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Result.error(401, "未登录");
        }
        String token = authHeader.substring(7);
        if (!jwtUtil.validateToken(token)) {
            return Result.error(401, "token无效或已过期");
        }
        String oldPassword = body != null ? body.get("oldPassword") : null;
        String newPassword = body != null ? body.get("newPassword") : null;
        if (oldPassword == null || oldPassword.trim().isEmpty()) {
            return Result.error("请输入原密码");
        }
        if (newPassword == null || newPassword.trim().isEmpty()) {
            return Result.error("请输入新密码");
        }
        if (newPassword.length() < 6) {
            return Result.error("新密码长度不能少于6位");
        }
        Long userId = jwtUtil.getUserIdFromToken(token);
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            return Result.error("用户不存在");
        }
        User user = userOptional.get();
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            return Result.error("原密码错误");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        logger.info("用户修改密码成功: userId={}", userId);
        return Result.success("密码修改成功，请重新登录", null);
    }
}
