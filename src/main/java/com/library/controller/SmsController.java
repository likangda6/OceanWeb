package com.library.controller;

import com.library.common.util.ResponseResult;
import com.library.service.AliyunSmsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

/**
 * 短信验证码接口
 * 注：赠送签名/模板仅支持 SendSmsVerifyCode 接口，
 *    该接口由阿里云自动生成验证码并返回，本控制器负责保存并校验。
 */
@Tag(name = "短信验证码")
@RestController
@RequestMapping("/api/sms")
public class SmsController {

    @Autowired
    private AliyunSmsService smsService;

    @Value("${aliyun.sms.interval-seconds:60}")
    private long intervalSeconds;

    @Value("${aliyun.sms.expire-minutes:5}")
    private long expireMinutes;

    // 手机号正则（中国大陆 11 位）
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");

    // 内存存储：手机号 -> [验证码字符串, 发送时间戳]
    // 注：单机部署足够；多实例部署需替换为 Redis
    private static final Map<String, Object[]> CODE_STORE = new ConcurrentHashMap<>();

    @Operation(summary = "发送注册验证码")
    @PostMapping("/code")
    public ResponseResult sendCode(@RequestParam String phone) {
        // 1. 手机号格式校验
        if (phone == null || !PHONE_PATTERN.matcher(phone).matches()) {
            return ResponseResult.error(400, "手机号格式不正确");
        }

        // 2. 60 秒限流
        Object[] entry = CODE_STORE.get(phone);
        long now = System.currentTimeMillis();
        if (entry != null) {
            long lastSendTs = (long) entry[1];
            long elapsed = (now - lastSendTs) / 1000;
            if (elapsed < intervalSeconds) {
                long wait = intervalSeconds - elapsed;
                return ResponseResult.error(429, "发送过于频繁，请 " + wait + " 秒后重试");
            }
        }

        // 3. 调用阿里云 SendSmsVerifyCode 接口发送（系统自动生成验证码）
        String verifyCode = smsService.sendVerifyCode(phone);
        if (verifyCode == null) {
            return ResponseResult.error(500, "短信发送失败，请稍后重试");
        }

        // 4. 保存阿里云返回的验证码与发送时间戳
        CODE_STORE.put(phone, new Object[]{verifyCode, now});

        return ResponseResult.success("验证码已发送，5 分钟内有效");
    }

    /**
     * 校验验证码（供注册接口调用）
     * @return true=校验通过
     */
    public boolean verifyCode(String phone, String inputCode) {
        if (phone == null || inputCode == null) return false;
        Object[] entry = CODE_STORE.get(phone);
        if (entry == null) return false;
        String storedCode = (String) entry[0];
        long sendTs = (long) entry[1];
        long now = System.currentTimeMillis();
        // 过期校验
        if ((now - sendTs) > expireMinutes * 60 * 1000) {
            CODE_STORE.remove(phone);
            return false;
        }
        if (!inputCode.equals(storedCode)) {
            return false;
        }
        // 验证成功后移除，避免重复使用
        CODE_STORE.remove(phone);
        return true;
    }
}
