package com.library.mapper;

import com.library.common.domain.dto.SpeciesStatisticsDTO;
import org.apache.ibatis.annotations.Mapper;

// SpeciesStatisticsMapper.java
@Mapper
public interface SpeciesStatisticsMapper {
    SpeciesStatisticsDTO countAllStatistics();
}