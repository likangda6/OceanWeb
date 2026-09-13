package com.library.controller;


import com.library.common.domain.entity.WhaleSpecies;
import com.library.common.util.ResponseResult;
import com.library.service.WhaleSpeciesService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Tag(name = "鲸类管理")
@RestController
@RequestMapping("/WhaleSpecies")
public class WhaleSpeciesController {

    @Autowired
    private  WhaleSpeciesService whaleSpeciesService;



    @GetMapping("/search")
    public ResponseResult getWhaleByName(@RequestParam String name) {
        WhaleSpecies whale = whaleSpeciesService.getWhaleByName(name);
        if (whale == null) {
            return ResponseResult.error(404, "无该哺乳动物信息");
        }
        return ResponseResult.success(whale);
    }

    @Operation(summary = "添加鲸类")
    @PostMapping("/add")
    public ResponseResult addWhale(@RequestBody WhaleSpecies whale) {
        whaleSpeciesService.addWhale(whale);
        return ResponseResult.success("添加成功");
    }

    @Operation(summary = "更新鲸类信息")
    @PutMapping("/update")
    public ResponseResult updateWhale(@RequestBody WhaleSpecies whale) {
        whaleSpeciesService.updateWhale(whale);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "删除鲸类")
    @DeleteMapping("/delete/{id}")
    public ResponseResult deleteWhale(@PathVariable Integer id) {
        whaleSpeciesService.deleteWhale(id);
        return ResponseResult.success("删除成功");
    }
}
