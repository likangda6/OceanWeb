package com.library.service;

import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.util.UUID;

/**
 * MinIO 对象存储服务
 */
@Slf4j
@Service
public class MinioService {

    @Autowired
    private MinioClient minioClient;

    @Value("${minio.bucket-name}")
    private String bucketName;

    @Value("${minio.img-dir}")
    private String imgDir;

    @Value("${minio.endpoint}")
    private String endpoint;

    @Value("${minio.secure}")
    private boolean secure;

    /**
     * 上传图片并返回可访问的 URL
     * @param inputStream 图片输入流
     * @param contentType 文件类型
     * @return 图片访问 URL
     */
    public String uploadImage(InputStream inputStream, String contentType, long size) {
        try {
            String fileName = imgDir + "/" + UUID.randomUUID() + ".jpg";
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(fileName)
                            .contentType(contentType != null ? contentType : "image/jpeg")
                            .stream(inputStream, size, -1)
                            .build());
            log.info("图片上传到 MinIO: {}", fileName);
            // 构建直接访问 URL（要求 bucket 设置为 public-read 或匿名读策略）
            String protocol = secure ? "https://" : "http://";
            String url = protocol + endpoint + "/" + bucketName + fileName;
            return url;
        } catch (Exception e) {
            log.error("MinIO 上传图片失败", e);
            return null;
        }
    }

    /**
     * 上传图片字节数组
     */
    public String uploadImage(byte[] bytes, String contentType) {
        try (InputStream is = new java.io.ByteArrayInputStream(bytes)) {
            return uploadImage(is, contentType, bytes.length);
        } catch (Exception e) {
            log.error("MinIO 上传图片失败", e);
            return null;
        }
    }
}
