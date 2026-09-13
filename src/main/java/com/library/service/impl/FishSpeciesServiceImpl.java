package com.library.service.impl;

import com.library.common.domain.entity.Fish;
import com.library.mapper.FishSpeciesMapper;
import com.library.mapper.WhaleSpeciesMapper;
import com.library.service.FishSpeciesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class FishSpeciesServiceImpl implements FishSpeciesService {
    @Autowired
    private FishSpeciesMapper fishSpeciesMapper;
    @Override
    public Fish getFishByName(String name){
        return fishSpeciesMapper.getFishByName(name);
    }

    @Override
    public int addFish(Fish fish) {
        return fishSpeciesMapper.insertFish(fish);
    }

    @Override
    public int updateFish(Fish fish) {
        return fishSpeciesMapper.updateFish(fish);
    }

    @Override
    public int deleteFish(Integer id) {
        return fishSpeciesMapper.deleteFish(id);
    }
}
