package com.library.controller;


import com.library.common.domain.dto.AnimalQueryDTO;
import com.library.common.domain.vo.AnimalVO;
import com.library.service.AnimalService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "动物综合查询")
@RestController
@RequestMapping("/animals")
public class AnimalController {

    private final AnimalService animalService;

    @Autowired
    public AnimalController(AnimalService animalService) {
        this.animalService = animalService;
    }

    @GetMapping("/search")
    public List<AnimalVO> search(@ModelAttribute AnimalQueryDTO query) {
        return animalService.search(query);
    }
}