package com.library.service.impl;

import com.library.common.domain.entity.Species;
import com.library.mapper.SpeciesMapper;
import com.library.service.SpeciesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SpeciesServiceImpl implements SpeciesService {

    @Autowired
    private SpeciesMapper speciesMapper;

    @Override
    public List<Species> getAllSpecies() {
        return speciesMapper.findAll();
    }

    @Override
    public List<Species> getSpeciesByClass(String fishClass) {
        return speciesMapper.findByClass(fishClass);
    }

    @Override
    public List<Species> getSpeciesByOrder(String order) {
        return speciesMapper.findByOrder(order);
    }

    @Override
    public List<Species> getSpeciesByFamily(String family) {
        return speciesMapper.findByFamily(family);
    }

    @Override
    public Species getSpeciesById(Integer id) {
        return speciesMapper.findById(id);
    }

    @Override
    public List<String> getAllClasses() {
        return speciesMapper.findAllClasses();
    }

    @Override
    public List<String> getAllOrders() {
        return speciesMapper.findAllOrders();
    }

    @Override
    public List<String> getAllFamilies() {
        return speciesMapper.findAllFamilies();
    }
}
