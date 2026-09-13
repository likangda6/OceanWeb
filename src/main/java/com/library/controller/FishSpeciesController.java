package com.library.controller;


import com.library.common.domain.entity.Fish;
import com.library.common.util.ResponseResult;
import com.library.service.FishSpeciesService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Tag(name = "鱼类管理")
@RestController
@RequestMapping("/FishSpecies")
public class FishSpeciesController {
    @Autowired
    private FishSpeciesService fishSpeciesService;
    @GetMapping("/search")
    public ResponseResult getFishByName(@RequestParam String name) {
        Fish fish = fishSpeciesService.getFishByName(name);
        if (fish == null) {
            return ResponseResult.error(404, "无该鱼类信息");
        }
        return ResponseResult.success(fish);
    }

    @Operation(summary = "添加鱼类")
    @PostMapping("/add")
    public ResponseResult addFish(@RequestBody Fish fish) {
        fishSpeciesService.addFish(fish);
        return ResponseResult.success("添加成功");
    }

    @Operation(summary = "更新鱼类信息")
    @PutMapping("/update")
    public ResponseResult updateFish(@RequestBody Fish fish) {
        fishSpeciesService.updateFish(fish);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "删除鱼类")
    @DeleteMapping("/delete/{id}")
    public ResponseResult deleteFish(@PathVariable Integer id) {
        fishSpeciesService.deleteFish(id);
        return ResponseResult.success("删除成功");
    }
}
