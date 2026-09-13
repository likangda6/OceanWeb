package com.library.common.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Knife4jConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("OceanWeb 海洋生物科普平台 API")
                        .version("1.0.0")
                        .description("基于 Spring Boot 的海洋生物科普网站 RESTful API 文档")
                        .contact(new Contact().name("OceanWeb").email("admin@oceanweb.com")));
    }
}
