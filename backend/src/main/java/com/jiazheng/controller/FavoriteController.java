package com.jiazheng.controller;

import com.jiazheng.common.Result;
import com.jiazheng.entity.Worker;
import com.jiazheng.service.FavoriteService;
import com.jiazheng.utils.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = "*")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping
    public Result<?> addFavorite(@RequestBody Map<String, Long> request,
                                 @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        Long workerId = request.get("workerId");
        
        if (workerId == null) {
            return Result.error("家政人员ID不能为空");
        }
        
        favoriteService.addFavorite(userId, workerId);
        return Result.success("收藏成功");
    }

    @DeleteMapping("/{workerId}")
    public Result<?> removeFavorite(@PathVariable Long workerId,
                                    @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        favoriteService.removeFavorite(userId, workerId);
        return Result.success("取消收藏成功");
    }

    @GetMapping
    public Result<List<Worker>> getUserFavorites(@RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        List<Worker> favorites = favoriteService.getUserFavorites(userId);
        return Result.success(favorites);
    }

    @GetMapping("/check/{workerId}")
    public Result<Boolean> checkFavorite(@PathVariable Long workerId,
                                         @RequestHeader("Authorization") String authHeader) {
        Long userId = getUserIdFromToken(authHeader);
        boolean isFavorite = favoriteService.isFavorite(userId, workerId);
        return Result.success(isFavorite);
    }

    private Long getUserIdFromToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new RuntimeException("未登录");
        }
        String token = authHeader.substring(7);
        return jwtUtil.getUserIdFromToken(token);
    }
}
