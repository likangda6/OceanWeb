package com.library.controller;


import com.library.common.domain.entity.Invertebrate;
import com.library.common.util.ResponseResult;
import com.library.service.InvertebrateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Tag(name = "无脊椎动物管理")
@RestController
@RequestMapping("/invertebrate")
public class invertebrateController {

    @Autowired
    private  InvertebrateService invertebrateService;



    @GetMapping("/search")
    public ResponseResult getInvertebrateByName(@RequestParam String name) {
        Invertebrate animal= invertebrateService.getInvertebrateByName(name);
        if (animal == null) {
            return ResponseResult.error(404, "无该无脊椎动物信息");
        }
        return ResponseResult.success(animal);
    }

    @Operation(summary = "添加无脊椎动物")
    @PostMapping("/add")
    public ResponseResult addInvertebrate(@RequestBody Invertebrate invertebrate) {
        invertebrateService.addInvertebrate(invertebrate);
        return ResponseResult.success("添加成功");
    }

    @Operation(summary = "更新无脊椎动物信息")
    @PutMapping("/update")
    public ResponseResult updateInvertebrate(@RequestBody Invertebrate invertebrate) {
        invertebrateService.updateInvertebrate(invertebrate);
        return ResponseResult.success("更新成功");
    }

    @Operation(summary = "删除无脊椎动物")
    @DeleteMapping("/delete/{id}")
    public ResponseResult deleteInvertebrate(@PathVariable Integer id) {
        invertebrateService.deleteInvertebrate(id);
        return ResponseResult.success("删除成功");
    }
}
