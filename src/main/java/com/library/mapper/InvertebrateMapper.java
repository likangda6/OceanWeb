package com.library.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.library.common.domain.entity.Animal;
import com.library.common.domain.entity.Invertebrate;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InvertebrateMapper {
    Invertebrate getInvertebrateByName(String name);

    List<Animal> findByCriteria(
            @Param("animalClass") String animalClass,
            @Param("order") String order,
            @Param("family") String family
    );

    int insertInvertebrate(Invertebrate invertebrate);
    int updateInvertebrate(Invertebrate invertebrate);
    int deleteInvertebrate(Integer id);

    /** 管理后台分页查询无脊椎动物 */
    IPage<Invertebrate> selectPage(IPage<Invertebrate> page, @Param("name") String name);

    /** 查询全部无脊椎动物 */
    List<Invertebrate> selectAll();
}
