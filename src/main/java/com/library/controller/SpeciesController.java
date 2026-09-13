package com.library.controller;

import com.library.common.domain.entity.Species;
import com.library.service.SpeciesService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "物种分类管理")
@RestController
@RequestMapping("/api/species")
public class SpeciesController {

    @Autowired
    private SpeciesService speciesService;

    @GetMapping
    public List<Species> getAllSpecies() {
        return speciesService.getAllSpecies();
    }

    @GetMapping("/classes")
    public List<String> getAllClasses() {
        return speciesService.getAllClasses();
    }

    @GetMapping("/orders")
    public List<String> getAllOrders() {
        return speciesService.getAllOrders();
    }

    @GetMapping("/families")
    public List<String> getAllFamilies() {
        return speciesService.getAllFamilies();
    }

    @GetMapping("/class/{fishClass}")
    public List<Species> getSpeciesByClass(@PathVariable String fishClass) {
        return speciesService.getSpeciesByClass(fishClass);
    }


    @GetMapping("/order/{order}")
    public List<Species> getSpeciesByOrder(@PathVariable String order) {
        return speciesService.getSpeciesByOrder(order);
    }

    @GetMapping("/family/{family}")
    public List<Species> getSpeciesByFamily(@PathVariable String family) {
        return speciesService.getSpeciesByFamily(family);
    }

    @GetMapping("/{id}")
    public Species getSpeciesById(@PathVariable Integer id) {
        return speciesService.getSpeciesById(id);
    }

    @GetMapping("/taxonomy-tree")
    public Map<String, Object> getTaxonomyTree() {
        // 构建分类树结构
        List<String> classes = speciesService.getAllClasses();

        Map<String, Object> tree = classes.stream().collect(Collectors.toMap(
                clazz -> clazz,
                clazz -> {
                    List<Species> classSpecies = speciesService.getSpeciesByClass(clazz);
                    Map<String, List<Species>> orders = classSpecies.stream()
                            .collect(Collectors.groupingBy(Species::getOrder));

                    return orders.entrySet().stream().collect(Collectors.toMap(
                            Map.Entry::getKey,
                            entry -> {
                                List<Species> orderSpecies = entry.getValue();
                                return orderSpecies.stream()
                                        .collect(Collectors.groupingBy(Species::getFamily));
                            }
                    ));
                }
        ));

        return tree;
    }
}