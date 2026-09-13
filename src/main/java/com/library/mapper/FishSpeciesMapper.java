package com.library.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.library.common.domain.entity.Animal;
import com.library.common.domain.entity.Fish;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FishSpeciesMapper {
    Fish getFishByName(String name);

    List<Animal> findByCriteria(
            @Param("animalClass") String animalClass,
            @Param("order") String order,
            @Param("family") String family
    );

    int insertFish(Fish fish);
    int updateFish(Fish fish);
    int deleteFish(Integer id);

    /** 管理后台分页查询鱼类（支持按名称模糊搜索） */
    IPage<Fish> selectPage(IPage<Fish> page, @Param("name") String name);

    /** 查询全部鱼类（用于后台统计/导出，不推荐大量数据使用） */
    List<Fish> selectAll();
}
