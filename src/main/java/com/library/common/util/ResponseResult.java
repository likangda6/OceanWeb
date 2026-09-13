package com.library.common.util;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ResponseResult {
    private int code;
    private String message;
    private Object data;

    public static ResponseResult success(Object data) {
        return new ResponseResult(200, "success", data);
    }

    public static ResponseResult error(int code, String message) {
        return new ResponseResult(code, message, null);
    }
}
