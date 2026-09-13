package com.library.common.config;

import com.library.common.domain.entity.User;
import com.library.common.util.JwtUtils;
import com.library.service.UserService;
import io.jsonwebtoken.Claims;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final UserService userService;

    public JwtAuthenticationFilter(@Lazy UserService userService) {
        this.userService = userService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        // 1) 优先从 Authorization 头读取 token
        String token = null;
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            token = header.substring(7);
        }
        // 2) 兼容 SSE：浏览器原生 EventSource 无法设置请求头，回退到 query 参数
        if (token == null) {
            String q = request.getParameter("token");
            if (q != null && !q.isEmpty()) {
                token = q;
            }
        }
        if (token != null) {
            try {
                if (!JwtUtils.isTokenExpired(token)) {
                    Claims claims = JwtUtils.parseToken(token);
                    String username = claims.get("username", String.class);
                    // 优先从数据库查询最新角色（角色变更立即生效，兼容旧 token）
                    String role = "ROLE_USER";
                    if (username != null) {
                        User user = userService.findByUsername(username);
                        if (user != null && user.getRole() != null && !user.getRole().isEmpty()) {
                            role = user.getRole();
                        }
                    }
                    // 设置认证信息
                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                            username, null, Collections.singletonList(new SimpleGrantedAuthority(role)));
                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            } catch (Exception e) {
                // token 无效，继续执行过滤链
            }
        }
        filterChain.doFilter(request, response);
    }
}
