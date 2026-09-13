package com.library.service;

import com.aliyun.oss.OSS;
import com.library.common.config.OssConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class OssService {

    @Autowired
    private OSS ossClient;

    @Autowired
    private OssConfig ossConfig;

    /**
     * 上传文件到 OSS
     */
    public String uploadFile(MultipartFile file) throws IOException {
        String originalFilename = file.getOriginalFilename();
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        String objectName = datePath + "/" + UUID.randomUUID().toString().replace("-", "") + ext;

        ossClient.putObject(ossConfig.getBucketName(), objectName, file.getInputStream());

        // 返回公网访问 URL
        return "https://" + ossConfig.getBucketName() + "." + ossConfig.getEndpoint() + "/" + objectName;
    }

    /**
     * 删除 OSS 文件
     */
    public void deleteFile(String fileUrl) {
        String bucketName = ossConfig.getBucketName();
        String endpoint = ossConfig.getEndpoint();
        String objectName = fileUrl.replace("https://" + bucketName + "." + endpoint + "/", "");
        ossClient.deleteObject(bucketName, objectName);
    }
}
