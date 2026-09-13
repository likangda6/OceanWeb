package com.library.service.impl;

import com.library.common.domain.entity.WhaleSpecies;

import com.library.mapper.WhaleSpeciesMapper;
import com.library.service.WhaleSpeciesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class WhaleSpeciesServiceImpl implements WhaleSpeciesService {
    @Autowired
    private WhaleSpeciesMapper whaleSpeciesMapper;

    @Override
    public  WhaleSpecies getWhaleByName(String name){
        return  whaleSpeciesMapper.getWhaleByName(name);
    }

    @Override
    public int addWhale(WhaleSpecies whale) {
        return whaleSpeciesMapper.insertWhale(whale);
    }

    @Override
    public int updateWhale(WhaleSpecies whale) {
        return whaleSpeciesMapper.updateWhale(whale);
    }

    @Override
    public int deleteWhale(Integer id) {
        return whaleSpeciesMapper.deleteWhale(id);
    }
}
