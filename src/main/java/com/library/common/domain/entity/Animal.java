package com.library.common.domain.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * @author 2405993739
 * @description: 鱼和鲸的实体类
 * @date 2025/7/31 10:36
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Animal {
    private int id;
    private String name;
    private String animalClass;
    private String order;
    private String family;
    private String description;
    private String imageUrl;
}