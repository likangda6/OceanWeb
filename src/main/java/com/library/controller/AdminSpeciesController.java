package com.library.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.library.common.domain.entity.Fish;
import com.library.common.domain.entity.Invertebrate;
import com.library.common.domain.entity.WhaleSpecies;
import com.library.common.domain.vo.PageResult;
import com.library.common.util.ResponseResult;
import com.library.mapper.FishSpeciesMapper;
import com.library.mapper.InvertebrateMapper;
import com.library.mapper.WhaleSpeciesMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 管理后台物种管理接口（仅管理员可访问，由 SecurityConfig 中 /api/admin/** hasRole(ADMIN) 控制）
 */
@Tag(name = "管理后台-物种管理")
@RestController
@RequestMapping("/api/admin/species")
public class AdminSpeciesController {

    @Autowired
    private FishSpeciesMapper fishMapper;

    @Autowired
    private WhaleSpeciesMapper whaleMapper;

    @Autowired
    private InvertebrateMapper invertebrateMapper;

    // ===================== 分页查询 =====================

    @Operation(summary = "分页查询鱼类")
    @GetMapping("/fish")
    public ResponseResult listFish(@RequestParam(defaultValue = "1") Integer page,
                                   @RequestParam(defaultValue = "10") Integer size,
                                   @RequestParam(required = false) String name) {
        IPage<Fish> p = new Page<>(page, size);
        IPage<Fish> result = fishMapper.selectPage(p, name);
        return ResponseResult.success(new PageResult<>(result.getCurrent(), result.getSize(),
                result.getTotal(), result.getPages(), result.getRecords()));
    }

    @Operation(summary = "分页查询鲸类")
    @GetMapping("/whale")
    public ResponseResult listWhale(@RequestParam(defaultValue = "1") Integer page,
                                    @RequestParam(defaultValue = "10") Integer size,
                                    @RequestParam(required = false) String name) {
        IPage<WhaleSpecies> p = new Page<>(page, size);
        IPage<WhaleSpecies> result = whaleMapper.selectPage(p, name);
        return ResponseResult.success(new PageResult<>(result.getCurrent(), result.getSize(),
                result.getTotal(), result.getPages(), result.getRecords()));
    }

    @Operation(summary = "分页查询无脊椎动物")
    @GetMapping("/invertebrate")
    public ResponseResult listInvertebrate(@RequestParam(defaultValue = "1") Integer page,
                                           @RequestParam(defaultValue = "10") Integer size,
                                           @RequestParam(required = false) String name) {
        IPage<Invertebrate> p = new Page<>(page, size);
        IPage<Invertebrate> result = invertebrateMapper.selectPage(p, name);
        return ResponseResult.success(new PageResult<>(result.getCurrent(), result.getSize(),
                result.getTotal(), result.getPages(), result.getRecords()));
    }

    // ===================== 新增 =====================

    @Operation(summary = "新增鱼类")
    @PostMapping("/fish")
    public ResponseResult addFish(@RequestBody Fish fish) {
        fishMapper.insertFish(fish);
        return ResponseResult.success("新增成功");
    }

    @Operation(summary = "新增鲸类")
    @PostMapping("/whale")
    public ResponseResult addWhale(@RequestBody WhaleSpecies whale) {
        whaleMapper.insertWhale(whale);
        return ResponseResult.success("新增成功");
    }

    @Operation(summary = "新增无脊椎动物")
    @PostMapping("/invertebrate")
    public ResponseResult addInvertebrate(@RequestBody Invertebrate invertebrate) {
        invertebrateMapper.insertInvertebrate(invertebrate);
        return ResponseResult.success("新增成功");
    }

    // ===================== 更新 =====================

    @Operation(summary = "更新鱼类")
    @PutMapping("/fish")
    public ResponseResult updateFish(@RequestBody Fish fish) {
        if (fish.getId() == 0) {
            return ResponseResult.error(400, "id不能为空");
        }
        fishMapper.updateFish(fish);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "更新鲸类")
    @PutMapping("/whale")
    public ResponseResult updateWhale(@RequestBody WhaleSpecies whale) {
        if (whale.getId() == 0) {
            return ResponseResult.error(400, "id不能为空");
        }
        whaleMapper.updateWhale(whale);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "更新无脊椎动物")
    @PutMapping("/invertebrate")
    public ResponseResult updateInvertebrate(@RequestBody Invertebrate invertebrate) {
        if (invertebrate.getId() == 0) {
            return ResponseResult.error(400, "id不能为空");
        }
        invertebrateMapper.updateInvertebrate(invertebrate);
        return ResponseResult.success("更新成功");
    }

    // ===================== 删除 =====================

    @Operation(summary = "删除鱼类")
    @DeleteMapping("/fish/{id}")
    public ResponseResult deleteFish(@PathVariable Integer id) {
        fishMapper.deleteFish(id);
        return ResponseResult.success("删除成功");
    }

    @Operation(summary = "删除鲸类")
    @DeleteMapping("/whale/{id}")
    public ResponseResult deleteWhale(@PathVariable Integer id) {
        whaleMapper.deleteWhale(id);
        return ResponseResult.success("删除成功");
    }

    @Operation(summary = "删除无脊椎动物")
    @DeleteMapping("/invertebrate/{id}")
    public ResponseResult deleteInvertebrate(@PathVariable Integer id) {
        invertebrateMapper.deleteInvertebrate(id);
        return ResponseResult.success("删除成功");
    }

    // ===================== 实时监控统计 =====================

    @Operation(summary = "管理后台实时监控：物种数量统计")
    @GetMapping("/dashboard")
    public ResponseResult dashboard() {
        Map<String, Object> data = new HashMap<>();
        data.put("fishCount", fishMapper.selectAll().size());
        data.put("whaleCount", whaleMapper.selectAll().size());
        data.put("invertebrateCount", invertebrateMapper.selectAll().size());
        long total = ((Integer) data.get("fishCount")).longValue()
                + ((Integer) data.get("whaleCount")).longValue()
                + ((Integer) data.get("invertebrateCount")).longValue();
        data.put("totalCount", total);
        data.put("timestamp", System.currentTimeMillis());
        return ResponseResult.success(data);
    }
}
