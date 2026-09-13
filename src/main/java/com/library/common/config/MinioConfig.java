package com.library.common.config;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.SetBucketPolicyArgs;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO 客户端配置
 */
@Slf4j
@Configuration
public class MinioConfig {

    @Value("${minio.endpoint}")
    private String endpoint;

    @Value("${minio.access-key}")
    private String accessKey;

    @Value("${minio.secret-key}")
    private String secretKey;

    @Value("${minio.bucket-name}")
    private String bucketName;

    @Value("${minio.secure}")
    private boolean secure;

    @Bean
    public MinioClient minioClient() {
        // 根据 secure 标志构建完整 endpoint URL
        String fullEndpoint = (secure ? "https://" : "http://") + endpoint;
        MinioClient client = MinioClient.builder()
                .endpoint(fullEndpoint)
                .credentials(accessKey, secretKey)
                .build();
        // 启动时自动创建 bucket 并设置公开读取策略（聊天图片需通过直接 URL 访问）
        try {
            boolean exists = client.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build());
            if (!exists) {
                client.makeBucket(MakeBucketArgs.builder().bucket(bucketName).build());
                log.info("MinIO bucket '{}' 创建成功", bucketName);
            } else {
                log.info("MinIO bucket '{}' 已存在", bucketName);
            }
            // 设置 bucket 为公开只读，否则直接 URL 访问会返回 403
            String policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::" + bucketName + "/*\"]}]}";
            client.setBucketPolicy(SetBucketPolicyArgs.builder().bucket(bucketName).config(policy).build());
            log.info("MinIO bucket '{}' 公开读取策略已设置", bucketName);
        } catch (Exception e) {
            log.warn("MinIO bucket 初始化失败（MinIO 可能未启动）: {}", e.getMessage());
        }
        return client;
    }
}
