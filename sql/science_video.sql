CREATE TABLE IF NOT EXISTS science_video (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL COMMENT '视频标题',
  description TEXT COMMENT '视频描述',
  video_id VARCHAR(100) NOT NULL COMMENT '阿里云VOD的VideoId',
  cover_url VARCHAR(500) COMMENT '封面图URL',
  duration BIGINT DEFAULT 0 COMMENT '视频时长(秒)',
  category VARCHAR(50) DEFAULT '科普视频' COMMENT '分类：科普视频/记录片段',
  status TINYINT DEFAULT 1 COMMENT '1-正常 0-下架',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='科普视频';
