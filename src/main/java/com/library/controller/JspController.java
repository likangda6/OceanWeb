package com.library.controller;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Tag(name = "页面导航")
@Controller
public class JspController {

    /**
     * 前后端分离入口：根路径重定向到 Vue 单页应用
     */
    @GetMapping("/")
    public String root() {
        return "redirect:/vue/";
    }

    /**
     * Vue 单页应用入口：访问 /vue 或 /vue/ 重定向到 /vue/index.html
     * 构建产物位于 src/main/resources/static/vue/ 下
     */
    @GetMapping({"/vue", "/vue/"})
    public String vueEntry() {
        return "redirect:/vue/index.html";
    }
}

