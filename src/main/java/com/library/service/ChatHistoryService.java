package com.library.service;

import com.library.common.domain.entity.ChatHistory;
import com.library.repository.ChatHistoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

/**
 * 聊天历史记录服务
 * - 按用户隔离（记忆隔离）
 * - 每用户最多保留 20 条
 * - 提供最近历史作为上下文
 */
@Slf4j
@Service
public class ChatHistoryService {

    private static final int MAX_HISTORY = 20;

    @Autowired
    private ChatHistoryRepository chatHistoryRepository;

    /**
     * 保存一条对话记录
     * 如果用户历史超过 20 条，删除最旧的一条
     */
    public ChatHistory saveHistory(Integer userId, String username,
                                   String userMessage, String aiMessage,
                                   String imageUrl, String type) {
        try {
            ChatHistory history = new ChatHistory();
            history.setUserId(userId);
            history.setUsername(username);
            history.setUserMessage(userMessage);
            history.setAiMessage(aiMessage);
            history.setImageUrl(imageUrl);
            history.setType(type != null ? type : "text");
            history.setCreatedAt(LocalDateTime.now());

            ChatHistory saved = chatHistoryRepository.save(history);

            // 超过上限时删除最旧记录
            long count = chatHistoryRepository.countByUserId(userId);
            if (count > MAX_HISTORY) {
                List<ChatHistory> all = chatHistoryRepository.findByUserIdOrderByCreatedAtDesc(
                        userId, PageRequest.of(0, (int) count, Sort.by(Sort.Direction.DESC, "createdAt")));
                // all 是按时间倒序，最后一个是最旧的
                if (!all.isEmpty()) {
                    ChatHistory oldest = all.get(all.size() - 1);
                    chatHistoryRepository.delete(oldest);
                    log.info("用户 {} 历史记录超过 {} 条，已删除最旧记录", userId, MAX_HISTORY);
                }
            }
            return saved;
        } catch (Exception e) {
            log.error("保存聊天历史失败", e);
            return null;
        }
    }

    /**
     * 获取用户最近的历史记录（按时间正序返回，用于 LLM 上下文）
     */
    public List<ChatHistory> getRecentHistory(Integer userId) {
        try {
            List<ChatHistory> desc = chatHistoryRepository.findByUserIdOrderByCreatedAtDesc(
                    userId, PageRequest.of(0, MAX_HISTORY, Sort.by(Sort.Direction.DESC, "createdAt")));
            // 反转为时间正序，便于作为上下文传入
            Collections.reverse(desc);
            return desc;
        } catch (Exception e) {
            log.error("获取聊天历史失败", e);
            return Collections.emptyList();
        }
    }

    /**
     * 构建历史上下文文本（用于纯文本 LLM）
     */
    public String buildContextText(Integer userId) {
        List<ChatHistory> history = getRecentHistory(userId);
        if (history.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("以下是用户与AI助手的最近对话历史，请参考这些上下文回答用户的新问题：\n\n");
        for (ChatHistory h : history) {
            sb.append("用户: ").append(h.getUserMessage()).append("\n");
            sb.append("AI: ").append(h.getAiMessage()).append("\n\n");
        }
        return sb.toString();
    }

    /**
     * 清空用户历史
     */
    public void clearHistory(Integer userId) {
        try {
            List<ChatHistory> all = chatHistoryRepository.findByUserIdOrderByCreatedAtDesc(
                    userId, PageRequest.of(0, Integer.MAX_VALUE, Sort.by(Sort.Direction.DESC, "createdAt")));
            chatHistoryRepository.deleteAll(all);
            log.info("已清空用户 {} 的聊天历史", userId);
        } catch (Exception e) {
            log.error("清空聊天历史失败", e);
        }
    }
}
