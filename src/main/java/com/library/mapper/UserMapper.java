package com.library.mapper;

import com.library.common.domain.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    User findByUsername(String username);
    int insertUser(User user);
}
