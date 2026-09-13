package com.library.service;

import com.library.common.domain.entity.User;

public interface UserService {
    User findByUsername(String username);
    int register(String username, String password);
}
