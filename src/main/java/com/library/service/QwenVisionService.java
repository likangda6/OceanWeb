package com.library.service;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * 通义千问 VL 视觉大模型服务
 * 通过 DashScope OpenAI 兼容接口调用 qwen-vl-max 模型
 */
@Slf4j
@Service
public class QwenVisionService {

    @Value("${dashscope.api-key}")
    private String apiKey;

    @Value("${dashscope.model}")
    private String model;

    @Value("${dashscope.base-url}")
    private String baseUrl;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /**
     * 识别图片中的海洋生物
     * @param imageBytes 图片字节数组
     * @return Map 包含: isMarine(boolean), name(String), reason(String)
     */
    public Map<String, Object> recognizeMarineSpecies(byte[] imageBytes) {
        Map<String, Object> result = new HashMap<>();
        try {
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            String dataUrl = "data:image/jpeg;base64," + base64Image;

            String prompt = "请识别这张图片中的生物。"
                    + "如果是海洋生物（鱼类、鲸豚类、无脊椎动物如章鱼/水母/珊瑚/虾蟹等），"
                    + "请返回JSON格式（不要其他内容）："
                    + "{\"isMarine\":true,\"name\":\"中文名称\",\"category\":\"鱼类|鲸类|无脊椎动物\"}"
                    + "。如果不是海洋生物（如陆地动物、植物、物品等），"
                    + "请返回JSON格式："
                    + "{\"isMarine\":false,\"name\":\"识别到的内容\",\"reason\":\"这不是海洋生物\"}";

            JsonObject responseBody = callQwenVlApi(dataUrl, prompt);
            String content = extractContent(responseBody);
            log.info("Qwen VL 识别结果: {}", content);

            // 解析JSON
            Map<String, Object> parsed = parseRecognitionJson(content);
            result.putAll(parsed);
        } catch (Exception e) {
            log.error("Qwen VL 识别失败", e);
            result.put("isMarine", false);
            result.put("name", "");
            result.put("reason", "识别服务异常: " + e.getMessage());
        }
        return result;
    }

    /**
     * 调用通义千问 LLM 生成物种详细信息（数据库中不存在时兜底）
     * @param speciesName 物种名称
     * @return Map 包含: name, animalClass, order, family, description
     */
    public Map<String, String> generateSpeciesInfo(String speciesName) {
        Map<String, String> result = new HashMap<>();
        try {
            String prompt = "请提供海洋生物\"" + speciesName + "\"的信息，严格返回以下JSON格式（不要其他内容）：\n"
                    + "{\"name\":\"" + speciesName + "\","
                    + "\"animalClass\":\"纲（如鱼纲、哺乳纲等）\","
                    + "\"order\":\"目\","
                    + "\"family\":\"科\","
                    + "\"description\":\"该物种的特征、习性、分布等描述（100-200字）\"}";

            JsonObject responseBody = callQwenTextApi(prompt);
            String content = extractContent(responseBody);
            log.info("Qwen LLM 生成物种信息: {}", content);

            result = parseSpeciesInfoJson(content);
        } catch (Exception e) {
            log.error("Qwen LLM 生成物种信息失败", e);
            result.put("name", speciesName);
            result.put("animalClass", "未知");
            result.put("order", "未知");
            result.put("family", "未知");
            result.put("description", "暂无详细描述");
        }
        return result;
    }

    /**
     * 多模态对话：带图片的问答
     * @param imageBytes 图片字节数组
     * @param question 用户问题
     * @param context 历史上下文（可为空）
     * @return AI 回答文本
     */
    public String chatWithImage(byte[] imageBytes, String question, String context) {
        try {
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            String dataUrl = "data:image/jpeg;base64," + base64Image;

            StringBuilder prompt = new StringBuilder();
            if (context != null && !context.isEmpty()) {
                prompt.append(context).append("\n");
            }
            prompt.append("用户问题：").append(question).append("\n");
            prompt.append("请根据图片内容回答用户关于海洋生物的问题。");
            prompt.append("如果图片不是海洋生物相关内容，请友好地说明并引导用户。");

            JsonObject responseBody = callQwenVlApi(dataUrl, prompt.toString());
            return extractContent(responseBody);
        } catch (Exception e) {
            log.error("Qwen VL 多模态对话失败", e);
            return "抱歉，图片识别服务暂时不可用，请稍后再试。";
        }
    }

    /**
     * 纯文本对话：调用 Qwen 文本模型
     * @param question 用户问题
     * @param context 历史上下文（可为空）
     * @return AI 回答文本
     */
    public String chatText(String question, String context) {
        try {
            String fullPrompt = question;
            if (context != null && !context.isEmpty()) {
                fullPrompt = context + "\n用户问题：" + question;
            }
            JsonObject responseBody = callQwenTextApi(fullPrompt);
            return extractContent(responseBody);
        } catch (Exception e) {
            log.error("Qwen 文本对话失败", e);
            return "抱歉，AI 服务暂时不可用，请稍后再试。";
        }
    }

    /**
     * 调用 Qwen VL 多模态接口
     */
    private JsonObject callQwenVlApi(String dataUrl, String prompt) throws Exception {
        JsonObject body = new JsonObject();
        body.addProperty("model", model);

        JsonArray messages = new JsonArray();
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");

        JsonArray content = new JsonArray();

        // 图片部分
        JsonObject imagePart = new JsonObject();
        imagePart.addProperty("type", "image_url");
        JsonObject imageUrl = new JsonObject();
        imageUrl.addProperty("url", dataUrl);
        imagePart.add("image_url", imageUrl);
        content.add(imagePart);

        // 文本部分
        JsonObject textPart = new JsonObject();
        textPart.addProperty("type", "text");
        textPart.addProperty("text", prompt);
        content.add(textPart);

        message.add("content", content);
        messages.add(message);
        body.add("messages", messages);

        return callApi(body);
    }

    /**
     * 调用 Qwen 文本接口（用于兜底生成物种信息）
     */
    private JsonObject callQwenTextApi(String prompt) throws Exception {
        JsonObject body = new JsonObject();
        body.addProperty("model", "qwen-max");

        JsonArray messages = new JsonArray();
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        message.addProperty("content", prompt);
        messages.add(message);
        body.add("messages", messages);

        return callApi(body);
    }

    /**
     * 调用 DashScope OpenAI 兼容接口
     */
    private JsonObject callApi(JsonObject body) throws Exception {
        String url = baseUrl + "/chat/completions";
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(60))
                .POST(HttpRequest.BodyPublishers.ofString(body.toString(), StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> res = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
        if (res.statusCode() != 200) {
            log.error("DashScope API 调用失败: {} {}", res.statusCode(), res.body());
            throw new RuntimeException("DashScope API 调用失败: " + res.statusCode());
        }
        return JsonParser.parseString(res.body()).getAsJsonObject();
    }

    /**
     * 从响应中提取 content 文本
     */
    private String extractContent(JsonObject responseBody) {
        try {
            JsonArray choices = responseBody.getAsJsonArray("choices");
            if (choices != null && choices.size() > 0) {
                JsonObject firstChoice = choices.get(0).getAsJsonObject();
                JsonObject message = firstChoice.getAsJsonObject("message");
                if (message != null) {
                    JsonElement content = message.get("content");
                    if (content != null) {
                        return content.getAsString();
                    }
                }
            }
        } catch (Exception e) {
            log.error("解析响应内容失败", e);
        }
        return "";
    }

    /**
     * 解析识别结果 JSON
     */
    private Map<String, Object> parseRecognitionJson(String content) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 提取 JSON 部分（可能包含 markdown 代码块）
            String jsonStr = extractJson(content);
            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();
            result.put("isMarine", json.get("isMarine").getAsBoolean());
            result.put("name", json.get("name").getAsString());
            if (json.has("category")) {
                result.put("category", json.get("category").getAsString());
            }
            if (json.has("reason")) {
                result.put("reason", json.get("reason").getAsString());
            }
        } catch (Exception e) {
            log.error("解析识别 JSON 失败: {}", content, e);
            result.put("isMarine", false);
            result.put("name", "");
            result.put("reason", "解析识别结果失败");
        }
        return result;
    }

    /**
     * 解析物种信息 JSON
     */
    private Map<String, String> parseSpeciesInfoJson(String content) {
        Map<String, String> result = new HashMap<>();
        try {
            String jsonStr = extractJson(content);
            JsonObject json = JsonParser.parseString(jsonStr).getAsJsonObject();
            result.put("name", json.get("name").getAsString());
            result.put("animalClass", json.get("animalClass").getAsString());
            result.put("order", json.get("order").getAsString());
            result.put("family", json.get("family").getAsString());
            result.put("description", json.get("description").getAsString());
        } catch (Exception e) {
            log.error("解析物种信息 JSON 失败: {}", content, e);
            result.put("name", "");
            result.put("animalClass", "未知");
            result.put("order", "未知");
            result.put("family", "未知");
            result.put("description", "暂无详细描述");
        }
        return result;
    }

    /**
     * 从可能包含 markdown 代码块的文本中提取 JSON
     */
    private String extractJson(String content) {
        if (content == null || content.isEmpty()) {
            return "{}";
        }
        // 去除 markdown 代码块
        String trimmed = content.trim();
        if (trimmed.startsWith("```")) {
            int start = trimmed.indexOf('\n');
            if (start > 0) {
                trimmed = trimmed.substring(start + 1);
            }
            int end = trimmed.lastIndexOf("```");
            if (end > 0) {
                trimmed = trimmed.substring(0, end);
            }
        }
        // 提取第一个 { 到最后一个 }
        int first = trimmed.indexOf('{');
        int last = trimmed.lastIndexOf('}');
        if (first >= 0 && last > first) {
            return trimmed.substring(first, last + 1);
        }
        return trimmed;
    }
}
