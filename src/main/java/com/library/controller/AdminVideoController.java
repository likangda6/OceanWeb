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
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

@Slf4j
@Tag(name = "管理后台-视频管理")
@RestController
@RequestMapping("/api/admin/videos")
public class AdminVideoController {

    @Autowired
    private VideoMapper videoMapper;

    @Autowired
    private AliyunVodService vodService;

    @Operation(summary = "分页查询视频列表")
    @GetMapping
    public ResponseResult list(@RequestParam(defaultValue = "1") Integer page,
                               @RequestParam(defaultValue = "10") Integer size,
                               @RequestParam(required = false) String title,
                               @RequestParam(required = false) String category) {
        IPage<ScienceVideo> p = new Page<>(page, size);
        IPage<ScienceVideo> result = videoMapper.selectAdminPage(p, title, category);
        return ResponseResult.success(new PageResult<>(result.getCurrent(), result.getSize(),
                result.getTotal(), result.getPages(), result.getRecords()));
    }

    @Operation(summary = "调试：列出所有可用的存储位置")
    @GetMapping("/debug/storage-locations")
    public ResponseResult listStorageLocations() {
        java.util.List<String> locations = vodService.listStorageLocations();
        return ResponseResult.success(locations);
    }

    @Operation(summary = "上传视频")
    @PostMapping
    public ResponseResult upload(@RequestParam("file") MultipartFile file,
                                 @RequestParam("title") String title,
                                 @RequestParam(value = "description", required = false) String description,
                                 @RequestParam(value = "category", defaultValue = "科普视频") String category) {
        if (file == null || file.isEmpty()) {
            return ResponseResult.error(400, "请选择视频文件");
        }
        try {
            // 上传到 VOD
            String videoId = vodService.uploadVideo(
                    title,
                    file.getOriginalFilename(),
                    file.getInputStream(),
                    file.getSize()
            );

            // 保存到数据库
            ScienceVideo video = new ScienceVideo();
            video.setTitle(title);
            video.setDescription(description);
            video.setVideoId(videoId);
            video.setCategory(category);
            videoMapper.insertVideo(video);

            log.info("视频上传成功: title={}, videoId={}", title, videoId);
            return ResponseResult.success("上传成功");
        } catch (Exception e) {
            log.error("视频上传失败", e);
            return ResponseResult.error(500, "上传失败: " + e.getMessage());
        }
    }

    @Operation(summary = "更新视频信息")
    @PutMapping("/{id}")
    public ResponseResult update(@PathVariable Integer id, @RequestBody ScienceVideo video) {
        video.setId(id);
        videoMapper.updateVideo(video);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "删除视频")
    @DeleteMapping("/{id}")
    public ResponseResult delete(@PathVariable Integer id) {
        ScienceVideo video = videoMapper.findById(id);
        if (video == null) {
            return ResponseResult.error(404, "视频不存在");
        }
        // 先从 VOD 删除
        try {
            vodService.deleteVideo(video.getVideoId());
        } catch (Exception e) {
            log.warn("VOD视频删除失败，继续删除数据库记录: {}", e.getMessage());
        }
        // 再从数据库删除
        videoMapper.deleteVideo(id);
        return ResponseResult.success("删除成功");
    }
}
