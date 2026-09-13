package com.library.service;

import com.library.common.domain.entity.Fish;
import com.library.common.domain.entity.WhaleSpecies;
import com.library.common.domain.vo.AnimalVO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;


public interface FishSpeciesService {
    Fish getFishByName(String name);

    int addFish(Fish fish);
    int updateFish(Fish fish);
    int deleteFish(Integer id);
}
