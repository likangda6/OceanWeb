package com.library.controller;

import com.library.common.config.PromptLoader;
import com.library.common.domain.entity.User;
import com.library.common.util.ResponseResult;
import com.library.service.AnimalService;
import com.library.service.ChatHistoryService;
import com.library.service.MinioService;
import com.library.service.QwenVisionService;
import com.library.service.UserService;
import io.github.lnyocly.ai4j.listener.SseListener;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.github.lnyocly.ai4j.platform.openai.chat.entity.ChatCompletion;
import io.github.lnyocly.ai4j.platform.openai.chat.entity.ChatMessage;
import io.github.lnyocly.ai4j.service.IChatService;
import io.github.lnyocly.ai4j.service.PlatformType;
import io.github.lnyocly.ai4j.service.factor.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;

@Tag(name = "AI智能交互")
@RestController
@RequestMapping("/ai")
@Slf4j
@RequiredArgsConstructor
public class AIReactiveController {

    private final AiService aiService;
    private final PromptLoader promptLoader;

    @Autowired
    private AnimalService animalService;

    @Autowired
    private QwenVisionService qwenVisionService;

    @Autowired
    private ChatHistoryService chatHistoryService;

    @Autowired
    private MinioService minioService;

    @Autowired
    private UserService userService;


    @Operation(summary = "AI流式对话")
    @GetMapping("/chatStream")
    public SseEmitter chatStream(@RequestParam String question,
                                 @AuthenticationPrincipal String username) {
        SseEmitter emitter = new SseEmitter(0L);
        emitter.onTimeout(() -> {
            log.warn("SSE 连接超时，手动关闭");
            emitter.complete();
        });

        // 获取用户信息和历史上下文
        User user = username != null ? userService.findByUsername(username) : null;
        Integer userId = user != null ? user.getId() : 0;
        String context = chatHistoryService.buildContextText(userId);

        Executors.newSingleThreadExecutor().submit(() -> {
            try {
                String systemPrompt = promptLoader.loadSystemPrompt();
                IChatService svc = aiService.getChatService(PlatformType.DEEPSEEK);
                ChatCompletion req = ChatCompletion.builder()
                        .model("deepseek-chat")
                        .message(ChatMessage.withSystem(systemPrompt))
                        .message(ChatMessage.withUser(context + "\n用户问题：" + question))
                        .build();

                SseListener listener = new SseListener() {
                    @Override
                    protected void send() {
                        try {
                            emitter.send(SseEmitter.event()
                                    .name("message")
                                    .data(this.getCurrData()));
                        } catch (IOException e) {
                            emitter.completeWithError(e);
                        }
                    }
                };

                final StringBuilder fullResponse = new StringBuilder();
                // 包装 listener：转发原始 chunk 给前端，同时解析出纯文本内容用于持久化
                SseListener wrappedListener = new SseListener() {
                    @Override
                    protected void send() {
                        try {
                            String chunk = this.getCurrData();
                            if (chunk != null) {
                                // 解析 OpenAI 风格的 chunk，提取 content 文本用于历史持久化
                                String content = extractDeltaContent(chunk);
                                if (content != null) {
                                    fullResponse.append(content);
                                }
                            }
                            emitter.send(SseEmitter.event()
                                    .name("message")
                                    .data(chunk));
                        } catch (IOException e) {
                            emitter.completeWithError(e);
                        }
                    }
                };

                emitter.onCompletion(() -> {
                    log.info("SSE 完成");
                    // 保存历史记录
                    String aiResponse = fullResponse.toString();
                    if (!aiResponse.isEmpty()) {
                        chatHistoryService.saveHistory(userId, username,
                                question, aiResponse, null, "text");
                    }
                    listener.getEventSource().cancel();
                });

                svc.chatCompletionStream(req, wrappedListener);
                emitter.complete();
            } catch (Exception ex) {
                emitter.completeWithError(ex);
            }
        });
        return emitter;
    }

    @Operation(summary = "多模态对话（文本+图片附件）")
    @PostMapping("/chatWithImage")
    public ResponseResult chatWithImage(@RequestParam("question") String question,
                                        @RequestParam(value = "image", required = false) MultipartFile imageFile,
                                        @AuthenticationPrincipal String username) {
        try {
            // 获取用户信息
            User user = username != null ? userService.findByUsername(username) : null;
            Integer userId = user != null ? user.getId() : 0;
            String context = chatHistoryService.buildContextText(userId);

            String answer;
            String imageUrl = null;
            String type;

            if (imageFile != null && !imageFile.isEmpty()) {
                // 带图片 → 上传 MinIO → 调用 Qwen VL
                byte[] imageBytes = imageFile.getBytes();
                imageUrl = minioService.uploadImage(imageBytes, imageFile.getContentType());
                answer = qwenVisionService.chatWithImage(imageBytes, question, context);
                type = "multimodal";
            } else {
                // 纯文本 → 调用 Qwen 文本模型
                answer = qwenVisionService.chatText(question, context);
                type = "text";
            }

            // 保存历史记录
            chatHistoryService.saveHistory(userId, username,
                    question, answer, imageUrl, type);

            Map<String, Object> data = new HashMap<>();
            data.put("answer", answer);
            data.put("imageUrl", imageUrl);
            return ResponseResult.success(data);
        } catch (Exception e) {
            log.error("多模态对话失败", e);
            return ResponseResult.error(500, "对话失败: " + e.getMessage());
        }
    }

    @Operation(summary = "获取聊天历史记录")
    @GetMapping("/history")
    public ResponseResult getHistory(@AuthenticationPrincipal String username) {
        try {
            User user = username != null ? userService.findByUsername(username) : null;
            if (user == null) {
                return ResponseResult.error(401, "未登录");
            }
            List<?> history = chatHistoryService.getRecentHistory(user.getId());
            return ResponseResult.success(history);
        } catch (Exception e) {
            log.error("获取历史记录失败", e);
            return ResponseResult.error(500, "获取历史记录失败");
        }
    }

    @Operation(summary = "清空聊天历史")
    @DeleteMapping("/history")
    public ResponseResult clearHistory(@AuthenticationPrincipal String username) {
        try {
            User user = username != null ? userService.findByUsername(username) : null;
            if (user == null) {
                return ResponseResult.error(401, "未登录");
            }
            chatHistoryService.clearHistory(user.getId());
            return ResponseResult.success("已清空");
        } catch (Exception e) {
            log.error("清空历史记录失败", e);
            return ResponseResult.error(500, "清空失败");
        }
    }

    @Operation(summary = "海洋生物图像识别")
    @PostMapping("/recognize")
    public ResponseResult recognizeAnimal(@RequestParam("image") MultipartFile imageFile) {
        return ResponseResult.success(animalService.recognizeAnimal(imageFile));
    }

    /**
     * 从 OpenAI 风格的 SSE chunk 中提取 delta.content 文本
     * chunk 形如：{"choices":[{"index":0,"delta":{"content":"xx"}}]}
     * 非 JSON 或无 content 字段时返回 null（如 [DONE] 标记）
     */
    private String extractDeltaContent(String chunk) {
        if (chunk == null || chunk.isEmpty() || "[DONE]".equals(chunk.trim())) {
            return null;
        }
        try {
            JsonObject obj = JsonParser.parseString(chunk).getAsJsonObject();
            if (obj.has("choices") && !obj.get("choices").isJsonNull()) {
                JsonObject first = obj.get("choices").getAsJsonArray().get(0).getAsJsonObject();
                if (first.has("delta") && !first.get("delta").isJsonNull()) {
                    JsonObject delta = first.getAsJsonObject("delta");
                    if (delta.has("content") && !delta.get("content").isJsonNull()) {
                        return delta.get("content").getAsString();
                    }
                }
            }
        } catch (Exception e) {
            log.debug("解析 SSE chunk 失败，跳过: {}", chunk);
        }
        return null;
    }
}
