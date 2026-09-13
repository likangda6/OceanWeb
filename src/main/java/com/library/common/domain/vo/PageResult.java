package com.library.common.domain.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 统一分页响应结果
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PageResult<T> {
    /** 当前页 */
    private long current;
    /** 每页大小 */
    private long size;
    /** 总记录数 */
    private long total;
    /** 总页数 */
    private long pages;
    /** 当前页数据列表 */
    private List<T> records;
}
