package com.library.service;

import com.library.common.domain.entity.Species;

import java.util.List;

public interface SpeciesService {
    List<Species> getAllSpecies();
    List<Species> getSpeciesByClass(String fishClass);
    List<Species> getSpeciesByOrder(String order);
    List<Species> getSpeciesByFamily(String family);
    Species getSpeciesById(Integer id);
    List<String> getAllClasses();
    List<String> getAllOrders();
    List<String> getAllFamilies();
}
