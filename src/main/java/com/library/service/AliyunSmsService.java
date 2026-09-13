package com.library.service;

import com.aliyun.dypnsapi20170525.Client;
import com.aliyun.dypnsapi20170525.models.SendSmsVerifyCodeRequest;
import com.aliyun.dypnsapi20170525.models.SendSmsVerifyCodeResponse;
import com.aliyun.teaopenapi.models.Config;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * 阿里云号码认证服务（DYPNS）- 短信验证码服务
 * 使用 SendSmsVerifyCode 接口，适配"赠送签名 + 赠送模板"。
 * 该接口由阿里云系统生成验证码并返回（ReturnVerifyCode=true）。
 */
@Service
public class AliyunSmsService {

    private static final Logger log = LoggerFactory.getLogger(AliyunSmsService.class);

    @Value("${aliyun.sms.access-key-id}")
    private String accessKeyId;

    @Value("${aliyun.sms.access-key-secret}")
    private String accessKeySecret;

    @Value("${aliyun.sms.sign-name}")
    private String signName;

    @Value("${aliyun.sms.template-code}")
    private String templateCode;

    private Client client;

    /**
     * 初始化 DYPNS 客户端（懒加载，避免启动时凭证错误导致应用启动失败）
     */
    private Client getClient() throws Exception {
        if (client == null) {
            Config config = new Config()
                    .setAccessKeyId(accessKeyId)
                    .setAccessKeySecret(accessKeySecret)
                    .setEndpoint("dypnsapi.aliyuncs.com");
            client = new Client(config);
        }
        return client;
    }

    /**
     * 发送短信验证码（使用 SendSmsVerifyCode 接口，适配赠送签名/模板）
     * 阿里云系统生成 6 位数字验证码并下发，同时返回验证码用于本地校验
     * @param phoneNumber 手机号（11位）
     * @return 发送成功返回 验证码（系统生成），失败返回 null
     */
    public String sendVerifyCode(String phoneNumber) {
        try {
            SendSmsVerifyCodeRequest request = new SendSmsVerifyCodeRequest()
                    .setPhoneNumber(phoneNumber)
                    .setSignName(signName)
                    .setTemplateCode(templateCode)
                    // 模板含 ${code} 和 ${min} 两个变量：
                    //  - code 使用 ##code## 占位符由阿里云系统生成验证码
                    //  - min 为有效期分钟数，与 ValidTime(秒) 一致
                    .setTemplateParam("{\"code\":\"##code##\",\"min\":\"5\"}")
                    .setCodeType(1L)             // 1=纯数字
                    .setCodeLength(6L)           // 6 位验证码
                    .setValidTime(300L)          // 5 分钟有效（与 min 字段保持一致）
                    .setInterval(60L)            // 60 秒发送间隔（阿里云端频控）
                    .setDuplicatePolicy(1L)      // 1=覆盖旧验证码
                    .setReturnVerifyCode(true);  // 返回验证码用于本地校验
            SendSmsVerifyCodeResponse response = getClient().sendSmsVerifyCode(request);
            String code = response.getBody().getCode();
            if ("OK".equals(code)) {
                String verifyCode = response.getBody().getModel().getVerifyCode();
                log.info("短信验证码发送成功, phone={}", phoneNumber);
                return verifyCode;
            } else {
                log.error("短信发送失败, phone={}, code={}, msg={}",
                        phoneNumber, code, response.getBody().getMessage());
                return null;
            }
        } catch (Exception e) {
            log.error("短信发送异常, phone={}", phoneNumber, e);
            return null;
        }
    }
}
