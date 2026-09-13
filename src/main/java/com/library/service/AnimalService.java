package com.library.service;

import com.library.common.domain.dto.AnimalQueryDTO;
import com.library.common.domain.vo.AnimalVO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface AnimalService {

    List<AnimalVO> search(AnimalQueryDTO query);

    Map<String, Object> recognizeAnimal(MultipartFile imageFile);
}
