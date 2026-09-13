package com.library.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.library.common.domain.entity.ScienceVideo;
import com.library.common.domain.vo.PageResult;
import com.library.common.util.ResponseResult;
import com.library.mapper.VideoMapper;
import com.library.service.AliyunVodService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Tag(name = "科普点播")
@RestController
@RequestMapping("/api/videos")
public class VideoController {

    @Autowired
    private VideoMapper videoMapper;

    @Autowired
    private AliyunVodService vodService;

    @Operation(summary = "分页查询视频列表")
    @GetMapping
    public ResponseResult list(@RequestParam(defaultValue = "1") Integer page,
                               @RequestParam(defaultValue = "12") Integer size,
                               @RequestParam(required = false) String category) {
        IPage<ScienceVideo> p = new Page<>(page, size);
        IPage<ScienceVideo> result = videoMapper.selectPublicPage(p, category);
        // 列表页补充封面：对当前页缺少封面的视频，从 VOD 获取首帧封面并回写数据库
        // VOD 转码完成需要时间，刚上传的视频可能仍无封面，下次刷新即可获取
        fillMissingCovers(result.getRecords());
        return ResponseResult.success(new PageResult<>(result.getCurrent(), result.getSize(),
                result.getTotal(), result.getPages(), result.getRecords()));
    }

    /**
     * 对列表中缺少封面、或封面URL已过期的视频，调用 VOD GetVideoInfo 获取最新封面URL并回写数据库。
     * VOD 返回的 coverURL 是带签名的临时 OSS URL（有效期约 17 小时），存库后会过期。
     * 本方法解析 URL 中的 Expires 参数，对已过期或剩余有效期不足 1 小时的 URL 实时刷新。
     * 为避免一次列表请求触发过多 VOD API 调用，最多只检查前 12 条需要刷新的记录。
     * VOD 查询失败时静默跳过，不影响列表返回。
     */
    private void fillMissingCovers(List<ScienceVideo> videos) {
        if (videos == null || videos.isEmpty()) return;
        int checked = 0;
        final int maxCheckPerRequest = 12;
        long now = System.currentTimeMillis() / 1000;
        for (ScienceVideo v : videos) {
            if (checked >= maxCheckPerRequest) break;
            if (v.getVideoId() == null || v.getVideoId().isEmpty()) continue;
            String url = v.getCoverUrl();
            boolean needCover = url == null || url.isEmpty();
            boolean expired = false;
            if (!needCover) {
                // 解析临时签名 URL 中的 Expires 参数，判断是否已过期或即将过期
                int idx = url.indexOf("Expires=");
                if (idx >= 0) {
                    String s = url.substring(idx + 8);
                    int end = s.indexOf('&');
                    if (end > 0) s = s.substring(0, end);
                    try {
                        long exp = Long.parseLong(s);
                        if (exp < now + 3600) { // 剩余不足 1 小时，需要刷新
                            expired = true;
                        }
                    } catch (NumberFormatException ignore) {
                    }
                }
            }
            boolean needDuration = v.getDuration() == null || v.getDuration() == 0;
            if (!needCover && !expired && !needDuration) continue;
            checked++;
            try {
                Map<String, Object> info = vodService.getVideoInfo(v.getVideoId());
                String coverUrl = (String) info.get("coverURL");
                Object durationObj = info.get("duration");
                Long duration = durationObj != null ? ((Number) durationObj).longValue() : 0L;
                if (coverUrl != null || duration > 0) {
                    videoMapper.updateCoverAndDuration(v.getId(), coverUrl, duration);
                    v.setCoverUrl(coverUrl);
                    v.setDuration(duration);
                }
            } catch (Exception e) {
                // 单条 VOD 查询失败不影响列表整体返回
                log.debug("列表填充封面失败, id={}, videoId={}: {}", v.getId(), v.getVideoId(), e.getMessage());
            }
        }
    }


    @Operation(summary = "获取视频详情")
    @GetMapping("/{id}")
    public ResponseResult detail(@PathVariable Integer id) {
        ScienceVideo video = videoMapper.findById(id);
        if (video == null) {
            return ResponseResult.error(404, "视频不存在");
        }
        // 如果封面为空、或封面URL已过期、或时长缺失，尝试从 VOD 获取最新并回写
        if (video.getVideoId() != null && needRefreshCover(video)) {
            try {
                Map<String, Object> info = vodService.getVideoInfo(video.getVideoId());
                String coverUrl = (String) info.get("coverURL");
                Object durationObj = info.get("duration");
                Long duration = durationObj != null ? ((Number) durationObj).longValue() : 0L;
                if (coverUrl != null || duration > 0) {
                    videoMapper.updateCoverAndDuration(id, coverUrl, duration);
                    video.setCoverUrl(coverUrl);
                    video.setDuration(duration);
                }
            } catch (Exception e) {
                // VOD 查询失败不影响详情返回
            }
        }
        return ResponseResult.success(video);
    }

    /**
     * 判断视频是否需要刷新封面URL：
     * - 封面为空 → 需要
     * - 时长为空或为 0 → 需要
     * - 封面URL含 Expires 参数且已过期或剩余不足 1 小时 → 需要
     */
    private boolean needRefreshCover(ScienceVideo video) {
        String url = video.getCoverUrl();
        if (url == null || url.isEmpty()) return true;
        if (video.getDuration() == null || video.getDuration() == 0) return true;
        int idx = url.indexOf("Expires=");
        if (idx < 0) return false; // 非临时签名 URL，无需刷新
        String s = url.substring(idx + 8);
        int end = s.indexOf('&');
        if (end > 0) s = s.substring(0, end);
        try {
            long exp = Long.parseLong(s);
            long now = System.currentTimeMillis() / 1000;
            return exp < now + 3600; // 剩余不足 1 小时即刷新
        } catch (NumberFormatException e) {
            return false;
        }
    }

    @Operation(summary = "获取播放凭证")
    @GetMapping("/{id}/play-info")
    public ResponseResult playInfo(@PathVariable Integer id) {
        ScienceVideo video = videoMapper.findById(id);
        if (video == null) {
            return ResponseResult.error(404, "视频不存在");
        }
        if (video.getVideoId() == null || video.getVideoId().isEmpty()) {
            return ResponseResult.error(400, "视频源缺失");
        }
        Map<String, Object> playInfo;
        try {
            playInfo = vodService.getPlayInfo(video.getVideoId());
        } catch (RuntimeException e) {
            String msg = e.getMessage() == null ? "" : e.getMessage();
            log.warn("获取播放信息失败, id={}, videoId={}, err={}", id, video.getVideoId(), msg);
            // 视频仍在转码中（Status=Transcoding / AuditStatus=Init），GetPlayInfo 不可调用
            if (msg.contains("Transcoding") || msg.contains("IllegalStatus")
                    || msg.contains("Status of the video is illegal")) {
                return ResponseResult.error(409, "视频正在转码中，请稍后 1-2 分钟后刷新重试");
            }
            // 其他异常返回通用错误
            return ResponseResult.error(500, "获取播放信息失败: " + msg);
        }
        Map<String, Object> data = new HashMap<>();
        data.put("title", video.getTitle());
        data.put("description", video.getDescription());
        data.putAll(playInfo);
        return ResponseResult.success(data);
    }
}
