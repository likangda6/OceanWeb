package com.library.controller;

import com.library.common.domain.entity.User;
import com.library.common.util.JwtUtils;
import com.library.common.util.ResponseResult;
import com.library.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "认证管理")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private SmsController smsController;

    @Operation(summary = "用户登录")
    @PostMapping("/login")
    public ResponseResult login(@RequestParam String username, @RequestParam String password) {
        User user = userService.findByUsername(username);
        if (user == null || !passwordEncoder.matches(password, user.getPassword())) {
            return ResponseResult.error(401, "用户名或密码错误");
        }
        String token = JwtUtils.generateToken(user.getId(), user.getUsername(), user.getRole());
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("username", user.getUsername());
        data.put("role", user.getRole());
        return ResponseResult.success(data);
    }

    @Operation(summary = "用户注册（需短信验证码）")
    @PostMapping("/register")
    public ResponseResult register(@RequestParam String username,
                                   @RequestParam String password,
                                   @RequestParam String phone,
                                   @RequestParam String code) {
        // 1. 验证码校验
        if (!smsController.verifyCode(phone, code)) {
            return ResponseResult.error(400, "验证码错误或已过期");
        }
        // 2. 注册
        try {
            userService.register(username, password);
            return ResponseResult.success("注册成功");
        } catch (RuntimeException e) {
            return ResponseResult.error(400, e.getMessage());
        }
    }

    @Operation(summary = "获取当前登录用户信息")
    @GetMapping("/me")
    public ResponseResult currentUser(@AuthenticationPrincipal String username) {
        if (username == null) {
            return ResponseResult.error(401, "未登录");
        }
        User user = userService.findByUsername(username);
        if (user == null) {
            return ResponseResult.error(404, "用户不存在");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("role", user.getRole());
        return ResponseResult.success(data);
    }
}
