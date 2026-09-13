package com.library.controller;

import com.library.common.domain.dto.SpeciesStatisticsDTO;
import com.library.service.SpeciesStatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "统计数据可视化")
@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    @Autowired
    private SpeciesStatisticsService statisticsService;

    @Operation(summary = "获取物种统计数据")
    @GetMapping
    public ResponseEntity<SpeciesStatisticsDTO> getStatistics() {
        SpeciesStatisticsDTO stats = statisticsService.getStatistics();
        return ResponseEntity.ok(stats);
    }
}