package com.quyenauto.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;

import java.io.IOException;

@Configuration
public class SecurityHeadersConfig {

    @Bean
    public FilterRegistrationBean<SecurityHeadersFilter> securityHeadersFilter() {
        FilterRegistrationBean<SecurityHeadersFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new SecurityHeadersFilter());
        registration.addUrlPatterns("/*");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return registration;
    }

    public static class SecurityHeadersFilter implements Filter {
        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            HttpServletResponse httpRes = (HttpServletResponse) response;

            httpRes.setHeader("X-Content-Type-Options", "nosniff");
            httpRes.setHeader("X-Frame-Options", "DENY");
            httpRes.setHeader("X-XSS-Protection", "1; mode=block");
            httpRes.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            httpRes.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
            httpRes.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

            chain.doFilter(request, response);
        }
    }
}
