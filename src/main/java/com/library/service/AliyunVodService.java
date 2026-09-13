package com.library.service;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.ObjectMetadata;
import com.aliyuncs.DefaultAcsClient;
import com.aliyuncs.IAcsClient;
import com.aliyuncs.profile.DefaultProfile;
import com.aliyuncs.vod.model.v20170321.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class AliyunVodService {

    @Value("${aliyun.vod.access-key-id}")
    private String accessKeyId;

    @Value("${aliyun.vod.access-key-secret}")
    private String accessKeySecret;

    @Value("${aliyun.vod.region}")
    private String region;

    @Value("${aliyun.vod.storage-location:}")
    private String storageLocation;

    private final Gson gson = new Gson();

    private IAcsClient createClient() {
        DefaultProfile profile = DefaultProfile.getProfile(region, accessKeyId, accessKeySecret);
        return new DefaultAcsClient(profile);
    }

    /**
     * 上传视频到阿里云 VOD
     * 1. 调用 CreateUploadVideo 获取上传凭证
     * 2. 解析 UploadAuth(临时OSS凭证) 和 UploadAddress(OSS目标地址)
     * 3. 使用 OSS SDK 上传文件
     * @return VOD VideoId
     */
    public String uploadVideo(String title, String fileName, InputStream inputStream, long size) {
        try {
            IAcsClient client = createClient();

            // 1. 创建上传凭证
            CreateUploadVideoRequest request = new CreateUploadVideoRequest();
            request.setTitle(title);
            request.setFileName(fileName);
            // 设置存储位置（在 VOD 控制台 → 配置管理 → 存储管理 中创建）
            if (storageLocation != null && !storageLocation.isEmpty()) {
                request.setStorageLocation(storageLocation);
            }
            CreateUploadVideoResponse response = client.getAcsResponse(request);

            String videoId = response.getVideoId();
            String uploadAuth = response.getUploadAuth();
            String uploadAddress = response.getUploadAddress();

            log.info("VOD上传凭证获取成功, VideoId={}, RequestId={}", videoId, response.getRequestId());

            // 2. 解析 base64 编码的凭证
            String authJson = new String(Base64.getDecoder().decode(uploadAuth), StandardCharsets.UTF_8);
            String addressJson = new String(Base64.getDecoder().decode(uploadAddress), StandardCharsets.UTF_8);

            JsonObject auth = gson.fromJson(authJson, JsonObject.class);
            JsonObject addr = gson.fromJson(addressJson, JsonObject.class);

            log.info("VOD UploadAuth 解析: {}", authJson);
            log.info("VOD UploadAddress 解析: {}", addressJson);

            String tempAccessKeyId = getJsonField(auth, "AccessKeyId", "accessKeyId", "accesskeyid");
            String tempAccessKeySecret = getJsonField(auth, "AccessKeySecret", "accessKeySecret", "accesskeysecret");
            // SecurityToken 可能为空字符串，需处理
            String tempSecurityToken = "";
            if (auth.has("SecurityToken") && !auth.get("SecurityToken").isJsonNull()) {
                tempSecurityToken = auth.get("SecurityToken").getAsString();
            } else if (auth.has("securityToken") && !auth.get("securityToken").isJsonNull()) {
                tempSecurityToken = auth.get("securityToken").getAsString();
            }

            String ossEndpoint = getJsonField(addr, "Endpoint", "EndPoint", "endpoint");
            if (!ossEndpoint.startsWith("http")) {
                ossEndpoint = "https://" + ossEndpoint;
            }
            String bucket = getJsonField(addr, "Bucket", "bucket");
            String objectKey = getJsonField(addr, "FileName", "fileName", "Object");

            log.info("OSS上传参数: endpoint={}, bucket={}, object={}, token长度={}",
                    ossEndpoint, bucket, objectKey, tempSecurityToken.length());

            // 3. 使用 OSS SDK 上传文件（使用 VOD 返回的临时凭证）
            // 使用 CredentialsProvider 显式设置 STS 临时凭证
            com.aliyun.oss.common.auth.DefaultCredentials credentials =
                    new com.aliyun.oss.common.auth.DefaultCredentials(
                            tempAccessKeyId, tempAccessKeySecret, tempSecurityToken);
            com.aliyun.oss.common.auth.DefaultCredentialProvider provider =
                    new com.aliyun.oss.common.auth.DefaultCredentialProvider(credentials);
            OSS ossClient = new OSSClientBuilder().build(ossEndpoint, provider);
            try {
                ObjectMetadata meta = new ObjectMetadata();
                meta.setContentLength(size);
                ossClient.putObject(bucket, objectKey, inputStream, meta);
                log.info("视频文件上传到 OSS 成功, bucket={}, object={}", bucket, objectKey);
            } finally {
                ossClient.shutdown();
            }

            return videoId;
        } catch (Exception e) {
            log.error("上传视频到 VOD 失败", e);
            throw new RuntimeException("上传视频失败: " + e.getMessage(), e);
        }
    }

    /**
     * 获取播放信息
     * @return Map 包含 VideoBase 和 PlayInfoList(播放地址列表)
     */
    public Map<String, Object> getPlayInfo(String videoId) {
        try {
            IAcsClient client = createClient();
            GetPlayInfoRequest request = new GetPlayInfoRequest();
            request.setVideoId(videoId);
            // 优先返回 HLS 切片格式（m3u8），支持边下边播，避免大视频卡顿
            request.setOutputType("cdn");
            GetPlayInfoResponse response = client.getAcsResponse(request);

            Map<String, Object> result = new HashMap<>();
            result.put("videoBase", response.getVideoBase());
            result.put("vid", videoId);
            // 单独调用 GetVideoPlayAuth 获取 playAuth，配合 Aliplayer 的 vid+playauth 模式播放
            // 此模式下播放器会自动选择切片格式和自适应码率，避免大视频整体下载导致卡顿
            try {
                GetVideoPlayAuthRequest authRequest = new GetVideoPlayAuthRequest();
                authRequest.setVideoId(videoId);
                GetVideoPlayAuthResponse authResponse = client.getAcsResponse(authRequest);
                result.put("playAuth", authResponse.getPlayAuth());
            } catch (Exception authEx) {
                log.warn("获取 PlayAuth 失败, 将降级为直链播放: {}", authEx.getMessage());
            }

            // 提取播放地址列表（同时保留 URL 方式作为兜底）
            java.util.List<Map<String, Object>> playInfoList = new java.util.ArrayList<>();
            if (response.getPlayInfoList() != null) {
                for (GetPlayInfoResponse.PlayInfo playInfo : response.getPlayInfoList()) {
                    Map<String, Object> info = new HashMap<>();
                    info.put("playURL", playInfo.getPlayURL());
                    info.put("format", playInfo.getFormat());
                    info.put("height", playInfo.getHeight());
                    info.put("width", playInfo.getWidth());
                    info.put("definition", playInfo.getDefinition());
                    info.put("duration", playInfo.getDuration());
                    playInfoList.add(info);
                }
            }
            result.put("playInfoList", playInfoList);

            log.info("获取播放信息成功, VideoId={}, 播放地址数={}, playAuth是否存在={}",
                    videoId,
                    playInfoList.size(),
                    result.containsKey("playAuth"));
            return result;
        } catch (Exception e) {
            log.error("获取播放信息失败, VideoId={}", videoId, e);
            throw new RuntimeException("获取播放信息失败: " + e.getMessage(), e);
        }
    }

    /**
     * 删除视频
     */
    public void deleteVideo(String videoId) {
        try {
            IAcsClient client = createClient();
            DeleteVideoRequest request = new DeleteVideoRequest();
            request.setVideoIds(videoId);
            client.getAcsResponse(request);
            log.info("VOD视频删除成功, VideoId={}", videoId);
        } catch (Exception e) {
            log.error("VOD视频删除失败, VideoId={}", videoId, e);
            throw new RuntimeException("删除视频失败: " + e.getMessage(), e);
        }
    }

    /**
     * 获取视频信息（封面URL、时长等）
     * @return Map 包含 coverURL, duration, status 等
     */
    public Map<String, Object> getVideoInfo(String videoId) {
        try {
            IAcsClient client = createClient();
            GetVideoInfoRequest request = new GetVideoInfoRequest();
            request.setVideoId(videoId);
            GetVideoInfoResponse response = client.getAcsResponse(request);

            Map<String, Object> result = new HashMap<>();
            GetVideoInfoResponse.Video video = response.getVideo();
            if (video != null) {
                result.put("coverURL", video.getCoverURL());
                result.put("duration", video.getDuration());
                result.put("status", video.getStatus());
                result.put("title", video.getTitle());
                result.put("description", video.getDescription());
            }
            return result;
        } catch (Exception e) {
            log.error("获取视频信息失败, VideoId={}", videoId, e);
            throw new RuntimeException("获取视频信息失败: " + e.getMessage(), e);
        }
    }

    /**
     * 列出当前账号下所有可用的存储位置
     * 用于排查 InvalidStorage.NotFound 错误
     */
    public List<String> listStorageLocations() {
        List<String> locations = new ArrayList<>();
        try {
            IAcsClient client = createClient();
            // 通过反射调用 DescribeVodStorageConfigRequest（不同 SDK 版本类名可能不同）
            Class<?> requestClass = Class.forName("com.aliyuncs.vod.model.v20170321.DescribeVodStorageConfigRequest");
            Object request = requestClass.getDeclaredConstructor().newInstance();
            // 设置分页参数
            requestClass.getMethod("setPageSize", Integer.class).invoke(request, 50);
            requestClass.getMethod("setPageNo", Integer.class).invoke(request, 1);

            Object response = client.getClass().getMethod("getAcsResponse", requestClass).invoke(client, request);

            // 解析响应中的 StorageConfigList
            Class<?> responseClass = response.getClass();
            // 尝试调用 getStorageConfigList 方法
            try {
                java.lang.reflect.Method getList = responseClass.getMethod("getStorageConfigList");
                List<?> configList = (List<?>) getList.invoke(response);
                for (Object config : configList) {
                    // 调用 getStorageLocation 方法
                    java.lang.reflect.Method getLocation = config.getClass().getMethod("getStorageLocation");
                    String location = (String) getLocation.invoke(config);
                    locations.add(location);
                }
            } catch (NoSuchMethodException e) {
                // 尝试其他方法名
                log.warn("无法通过 getStorageConfigList 获取存储位置列表，尝试其他方式");
            }
        } catch (ClassNotFoundException e) {
            log.warn("当前 SDK 版本不支持 DescribeVodStorageConfigRequest: {}", e.getMessage());
        } catch (Exception e) {
            log.error("获取存储位置列表失败", e);
        }
        return locations;
    }

    /**
     * 兼容不同大小写的 JSON 字段获取
     */
    private String getJsonField(JsonObject obj, String... fieldNames) {
        for (String name : fieldNames) {
            if (obj.has(name) && !obj.get(name).isJsonNull()) {
                return obj.get(name).getAsString();
            }
        }
        throw new RuntimeException("JSON 中找不到字段: " + String.join("/", fieldNames) + ", 实际字段: " + obj.keySet());
    }
}
