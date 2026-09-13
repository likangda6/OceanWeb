package com.library.common.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author 2405993739
 * @description: 鱼和鲸鱼的VO类
 * @date 2025/7/31 9:44
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AnimalVO {
    private int id;
    private String name;
    private String animalClass;
    private String order;
    private String family;
    private String description;
    private String imageUrl;

    public AnimalVO(String name, String animalClass, String order, String family, String description, String imageUrl) {
        this.name = name;
        this.animalClass = animalClass;
        this.order = order;
        this.family = family;
        this.description = description;
        this.imageUrl = imageUrl;
    }
}