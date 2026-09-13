package com.library.common.domain.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

/**
 * 聊天历史记录实体（MongoDB）
 * 每条记录代表一轮对话（用户提问 + AI回答）
 */
@Data
@Document(collection = "chat_history")
public class ChatHistory {

    @Id
    private String id;

    /** 用户 ID（记忆隔离关键字段） */
    private Integer userId;

    /** 用户名（便于排查） */
    private String username;

    /** 用户提问 */
    private String userMessage;

    /** AI 回答 */
    private String aiMessage;

    /** 用户上传图片的 MinIO 访问地址（可为空） */
    private String imageUrl;

    /** 对话类型：text / multimodal */
    private String type;

    /** 创建时间 */
    private LocalDateTime createdAt;
}
