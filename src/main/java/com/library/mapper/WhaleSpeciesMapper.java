package com.library.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.library.common.domain.entity.Animal;
import org.apache.ibatis.annotations.Mapper;
import com.library.common.domain.entity.WhaleSpecies;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface WhaleSpeciesMapper {

    WhaleSpecies getWhaleByName(String name);


    List<Animal> findByCriteria(
            @Param("animalClass") String animalClass,
            @Param("order") String order,
            @Param("family") String family
    );

    int insertWhale(WhaleSpecies whale);
    int updateWhale(WhaleSpecies whale);
    int deleteWhale(Integer id);

    /** 管理后台分页查询鲸类 */
    IPage<WhaleSpecies> selectPage(IPage<WhaleSpecies> page, @Param("name") String name);

    /** 查询全部鲸类 */
    List<WhaleSpecies> selectAll();
}
