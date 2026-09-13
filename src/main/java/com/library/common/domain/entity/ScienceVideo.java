package com.library.common.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ScienceVideo {
    private Integer id;
    private String title;
    private String description;
    private String videoId;      // 阿里云VOD的VideoId
    private String coverUrl;    // 封面图URL
    private Long duration;      // 视频时长(秒)
    private String category;   // 分类：科普视频/记录片段
    private Integer status;     // 1-正常 0-下架
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
