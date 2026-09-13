package com.library.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.library.common.domain.entity.ScienceVideo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface VideoMapper {
    // 分页查询（前台公开接口：只查 status=1 的）
    IPage<ScienceVideo> selectPublicPage(IPage<ScienceVideo> page, @Param("category") String category);

    // 分页查询（管理后台：可查所有状态）
    IPage<ScienceVideo> selectAdminPage(IPage<ScienceVideo> page, @Param("title") String title, @Param("category") String category);

    // 按ID查询
    ScienceVideo findById(@Param("id") Integer id);

    // 按videoId查询
    ScienceVideo findByVideoId(@Param("videoId") String videoId);

    // 新增
    int insertVideo(ScienceVideo video);

    // 更新（标题、描述、分类）
    int updateVideo(ScienceVideo video);

    // 更新封面和时长（VOD转码完成后回写）
    int updateCoverAndDuration(@Param("id") Integer id, @Param("coverUrl") String coverUrl, @Param("duration") Long duration);

    // 删除
    int deleteVideo(@Param("id") Integer id);

    // 查询全部（用于统计）
    List<ScienceVideo> selectAll();
}
