package com.library.common.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SpeciesStatisticsDTO {
    private Long classCount;    // 纲数
    private Long orderCount;    // 目数
    private Long familyCount;   // 科数
    private Long speciesCount;  // 物种总数
}