package com.library.mapper;
import com.library.common.domain.entity.Species;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SpeciesMapper {
    @Select("SELECT * FROM totalspecies")
    List<Species> findAll();

    @Select("SELECT * FROM totalspecies WHERE fishClass = #{fishClass}")
    List<Species> findByClass(String fishClass);

    @Select("SELECT * FROM totalspecies WHERE `order` = #{order}")
    List<Species> findByOrder(String order);

    @Select("SELECT * FROM totalspecies WHERE family = #{family}")
    List<Species> findByFamily(String family);

    @Select("SELECT * FROM totalspecies WHERE id = #{id}")
    Species findById(Integer id);

    @Select("SELECT DISTINCT fishClass FROM totalspecies")
    List<String> findAllClasses();

    @Select("SELECT DISTINCT `order` FROM totalspecies")
    List<String> findAllOrders();

    @Select("SELECT DISTINCT family FROM totalspecies")
    List<String> findAllFamilies();
}