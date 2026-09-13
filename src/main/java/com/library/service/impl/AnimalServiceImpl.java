package com.library.service.impl;

import com.library.common.domain.dto.AnimalQueryDTO;
import com.library.common.domain.entity.Animal;
import com.library.common.domain.entity.Fish;
import com.library.common.domain.entity.WhaleSpecies;
import com.library.common.domain.entity.Invertebrate;
import com.library.common.domain.vo.AnimalVO;
import com.library.mapper.FishSpeciesMapper;
import com.library.mapper.InvertebrateMapper;
import com.library.mapper.WhaleSpeciesMapper;
import com.library.service.AnimalService;
import com.library.service.QwenVisionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class AnimalServiceImpl implements AnimalService {

    private final FishSpeciesMapper fishSpeciesMapper;
    private final WhaleSpeciesMapper whaleSpeciesMapper;
    private final InvertebrateMapper invertebrateMapper;

    @Autowired
    private QwenVisionService qwenVisionService;

    private static final String MAMMAL_CLASS = "哺乳纲";

    @Autowired
    public AnimalServiceImpl(FishSpeciesMapper fishSpeciesMapper, WhaleSpeciesMapper whaleSpeciesMapper, InvertebrateMapper invertebrateMapper) {
        this.fishSpeciesMapper = fishSpeciesMapper;
        this.whaleSpeciesMapper = whaleSpeciesMapper;
        this.invertebrateMapper = invertebrateMapper;
    }

    @Override
    public List<AnimalVO> search(AnimalQueryDTO query) {
        List<Animal> fishes = fishSpeciesMapper.findByCriteria(query.getAnimalClass(), query.getOrder(), query.getFamily());
        List<Animal> whales = whaleSpeciesMapper.findByCriteria(query.getAnimalClass(), query.getOrder(), query.getFamily());
        List<Animal> invertebrate = invertebrateMapper.findByCriteria(query.getAnimalClass(), query.getOrder(), query.getFamily());

        List<AnimalVO> results = new ArrayList<>();
        for (Animal a : fishes) {
            AnimalVO vo = new AnimalVO();
            BeanUtils.copyProperties(a, vo);
            results.add(vo);
        }
        for (Animal a : whales) {
            AnimalVO vo = new AnimalVO();
            BeanUtils.copyProperties(a, vo);
            vo.setAnimalClass(MAMMAL_CLASS);
            results.add(vo);
        }
        for (Animal a : invertebrate) {
            AnimalVO vo = new AnimalVO();
            BeanUtils.copyProperties(a, vo);
            results.add(vo);
        }
        return results;
    }

    /**
     * 通义千问 VL 识别海洋生物流程：
     * 1. Qwen VL 识别图片 → 判断是否海洋生物 + 物种名称
     * 2. 非海洋生物 → 返回提示信息
     * 3. 查数据库 → 有记录则返回 DB 信息
     * 4. DB 无记录 → 调用 LLM 生成物种信息
     */
    @Override
    public Map<String, Object> recognizeAnimal(MultipartFile imageFile) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 1. 校验图片
            if (imageFile.isEmpty()) {
                result.put("success", false);
                result.put("message", "请上传有效的图片文件");
                return result;
            }
            String contentType = imageFile.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                result.put("success", false);
                result.put("message", "仅支持图片格式");
                return result;
            }
            if (imageFile.getSize() > 4 * 1024 * 1024) {
                result.put("success", false);
                result.put("message", "图片大小不能超过4MB");
                return result;
            }

            // 2. 调用 Qwen VL 识别
            Map<String, Object> recognition = qwenVisionService.recognizeMarineSpecies(imageFile.getBytes());
            boolean isMarine = Boolean.TRUE.equals(recognition.get("isMarine"));
            String speciesName = (String) recognition.get("name");

            // 3. 非海洋生物 → 返回提示
            if (!isMarine) {
                result.put("success", false);
                result.put("notMarine", true);
                result.put("message", "识别到：" + speciesName + "，这不是海洋生物，请重新上传海洋生物图片");
                return result;
            }

            // 4. 查数据库
            AnimalVO animalVO = getAnimalInfoFromDatabase(speciesName);

            if (animalVO != null) {
                // DB 有记录 → 返回 DB 信息
                result.put("success", true);
                result.put("source", "database");
                result.put("data", animalVO);
                return result;
            }

            // 5. DB 无记录 → 调用 LLM 生成物种信息
            Map<String, String> llmInfo = qwenVisionService.generateSpeciesInfo(speciesName);
            AnimalVO generatedVO = new AnimalVO();
            generatedVO.setName(llmInfo.get("name"));
            generatedVO.setAnimalClass(llmInfo.get("animalClass"));
            generatedVO.setOrder(llmInfo.get("order"));
            generatedVO.setFamily(llmInfo.get("family"));
            generatedVO.setDescription(llmInfo.get("description"));
            generatedVO.setImageUrl("");

            result.put("success", true);
            result.put("source", "ai");
            result.put("data", generatedVO);
            return result;

        } catch (Exception e) {
            log.error("识别动物失败", e);
            result.put("success", false);
            result.put("message", "识别失败: " + e.getMessage());
            return result;
        }
    }

    private AnimalVO getAnimalInfoFromDatabase(String animalName) {
        if (animalName == null || animalName.isEmpty()) {
            return null;
        }
        // 依次查询 fish / whale / invertebrate
        AnimalVO vo = queryFishSpecies(animalName);
        if (vo == null) {
            vo = queryWhaleSpecies(animalName);
        }
        if (vo == null) {
            vo = queryInvertebrate(animalName);
        }
        return vo;
    }

    private AnimalVO queryFishSpecies(String animalName) {
        Fish fish = fishSpeciesMapper.getFishByName(animalName);
        if (fish != null) {
            return new AnimalVO(fish.getName(), fish.getFishClass(), fish.getOrder(), fish.getFamily(), fish.getDescription(), fish.getImageUrl());
        }
        return null;
    }

    private AnimalVO queryWhaleSpecies(String animalName) {
        WhaleSpecies whaleSpecies = whaleSpeciesMapper.getWhaleByName(animalName);
        if (whaleSpecies != null) {
            return new AnimalVO(whaleSpecies.getName(), whaleSpecies.getFishClass(), whaleSpecies.getOrder(), whaleSpecies.getFamily(), whaleSpecies.getDescription(), whaleSpecies.getImageUrl());
        }
        return null;
    }

    private AnimalVO queryInvertebrate(String animalName) {
        Invertebrate invertebrate = invertebrateMapper.getInvertebrateByName(animalName);
        if (invertebrate != null) {
            return new AnimalVO(invertebrate.getName(), invertebrate.getFishClass(), invertebrate.getOrder(), invertebrate.getFamily(), invertebrate.getDescription(), invertebrate.getImageUrl());
        }
        return null;
    }
}
