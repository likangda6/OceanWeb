package com.library.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * @author 2405993739
 * @description: 读取ai身份提示文件
 * @date 2025/7/18 22:50
 */
@Component
public class PromptLoader {

    @Value("classpath:prompts/knowledge.txt")
    private Resource systemPromptResource;

    /**
     * 读取并返回 system-prompt.txt 的全部内容
     */
    public String loadSystemPrompt() {
        try (var in = systemPromptResource.getInputStream()) {
            byte[] bytes = in.readAllBytes();
            return new String(bytes, StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("无法加载 system-prompt.txt", e);
        }
    }
}
