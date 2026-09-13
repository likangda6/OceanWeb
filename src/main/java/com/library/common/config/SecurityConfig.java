package com.library.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors().and()
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
                // 认证相关接口：登录/注册/获取当前用户
                .antMatchers("/api/auth/login", "/api/auth/register").permitAll()
                .antMatchers("/api/auth/me").authenticated()
                // 短信验证码接口（注册时发送验证码）
                .antMatchers("/api/sms/**").permitAll()
                // Vue 单页应用入口及静态资源
                .antMatchers("/", "/vue", "/vue/**").permitAll()
                // Knife4j / Swagger 文档
                .antMatchers("/doc.html", "/doc.html/**", "/swagger-ui/**", "/swagger-ui.html",
                        "/v3/api-docs", "/v3/api-docs/**", "/swagger-config",
                        "/webjars/**", "/favicon.ico").permitAll()
                // 静态资源
                .antMatchers("/static/**", "/images/**", "/js/**").permitAll()
                // 公开数据接口（首页统计、物种检索、AI识别、生物图谱）
                .antMatchers("/api/statistics", "/animals/search",
                        "/FishSpecies/search", "/WhaleSpecies/search", "/invertebrate/search",
                        "/ai/chatStream", "/ai/recognize", "/ai/chatWithImage",
                        "/api/species/**").permitAll()
                // 科普点播公开接口（视频列表、详情、播放信息）
                .antMatchers("/api/videos/**").permitAll()
                // 管理员接口（管理后台 CRUD + 实时监控）
                .antMatchers("/api/admin/**").hasRole("ADMIN")
                // 其他接口需登录
                .anyRequest().authenticated()
            .and()
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
