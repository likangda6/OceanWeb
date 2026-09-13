package com.library.service;

import com.library.common.domain.entity.WhaleSpecies;

import org.springframework.stereotype.Service;


public interface WhaleSpeciesService {
      WhaleSpecies getWhaleByName(String name);

      int addWhale(WhaleSpecies whale);
      int updateWhale(WhaleSpecies whale);
      int deleteWhale(Integer id);
}
