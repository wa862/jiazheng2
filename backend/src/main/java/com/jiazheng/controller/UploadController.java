package com.jiazheng.controller;

import com.jiazheng.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
@CrossOrigin(origins = "*")
public class UploadController {

    private static final List<String> ALLOWED_TYPES = Arrays.asList("image/jpeg", "image/png", "image/webp", "image/gif");
    private static final long MAX_SIZE = 2 * 1024 * 1024; // 2MB

    @Value("${upload.path:./uploads}")
    private String uploadPath;

    /**
     * 上传图片，保存到服务器 uploads 目录，返回可访问路径（如 /uploads/xxx.png）
     */
    @PostMapping("/image")
    public Result<String> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.error("请选择图片文件");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
            return Result.error("仅支持 jpg/png/webp/gif 格式");
        }
        if (file.getSize() > MAX_SIZE) {
            return Result.error("图片大小不能超过 2MB");
        }
        try {
            String ext = "";
            String originalName = file.getOriginalFilename();
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf("."));
            } else {
                ext = ".png";
            }
            String fileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().replace("-", "").substring(0, 8) + ext;
            // 使用绝对路径作为上传目录，避免 Tomcat 工作目录下的相对路径问题
            Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
            if (!Files.exists(dir)) {
                Files.createDirectories(dir);
            }
            Path dest = dir.resolve(fileName);
            // 手动写入文件，避免 StandardMultipartFile.transferTo 对相对路径的特殊处理
            Files.copy(file.getInputStream(), dest, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            String relativePath = "uploads/" + fileName;
            return Result.success(relativePath);
        } catch (IOException e) {
            e.printStackTrace();
            return Result.error("上传失败: " + e.getMessage());
        }
    }
}
