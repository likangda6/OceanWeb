package com.library.service.impl;

import com.library.common.domain.dto.SpeciesStatisticsDTO;
import com.library.mapper.SpeciesStatisticsMapper;
import com.library.service.SpeciesStatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SpeciesStatisticsServiceImpl implements SpeciesStatisticsService {
    @Autowired
    private SpeciesStatisticsMapper statisticsMapper;

    public SpeciesStatisticsDTO getStatistics() {
        return statisticsMapper.countAllStatistics();
    }
}
