package com.library.common.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 管理后台统一物种视图对象（合并鱼类/鲸类/无脊椎动物）
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class SpeciesVO {
    private Integer id;
    private String name;
    /** 物种类别：fish / whale / invertebrate */
    private String category;
    /** 纲 */
    private String animalClass;
    /** 目 */
    private String order;
    /** 科 */
    private String family;
    /** 属 */
    private String genus;
    /** 学名 */
    private String scientificName;
    private String description;
    private String imageUrl;
}
