package com.library.repository;

import com.library.common.domain.entity.ChatHistory;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 聊天历史记录 MongoDB Repository
 */
@Repository
public interface ChatHistoryRepository extends MongoRepository<ChatHistory, String> {

    /**
     * 按 userId 查询历史记录，按创建时间升序返回（用于取最近 N 条作为上下文）
     */
    List<ChatHistory> findByUserIdOrderByCreatedAtDesc(Integer userId, Pageable pageable);

    /**
     * 统计某用户的历史记录数
     */
    long countByUserId(Integer userId);
}
