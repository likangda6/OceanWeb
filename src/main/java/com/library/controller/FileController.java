package com.library.controller;

import com.library.common.util.ResponseResult;
import com.library.service.OssService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "多媒体资源管理")
@RestController
@RequestMapping("/api/file")
public class FileController {

    @Autowired
    private OssService ossService;

    @Operation(summary = "上传图片/文件到OSS")
    @PostMapping("/upload")
    public ResponseResult uploadFile(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseResult.error(400, "文件不能为空");
            }
            String url = ossService.uploadFile(file);
            return ResponseResult.success(url);
        } catch (Exception e) {
            return ResponseResult.error(500, "文件上传失败: " + e.getMessage());
        }
    }

    @Operation(summary = "删除OSS文件")
    @DeleteMapping("/delete")
    public ResponseResult deleteFile(@RequestParam String fileUrl) {
        try {
            ossService.deleteFile(fileUrl);
            return ResponseResult.success("删除成功");
        } catch (Exception e) {
            return ResponseResult.error(500, "文件删除失败: " + e.getMessage());
        }
    }
}
