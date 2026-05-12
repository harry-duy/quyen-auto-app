package com.quyenauto.config;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.http.HttpStatus;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class RateLimitConfig {

    @Bean
    public FilterRegistrationBean<RateLimitFilter> rateLimitFilter() {
        FilterRegistrationBean<RateLimitFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new RateLimitFilter());
        registration.addUrlPatterns("/api/v1/auth/*");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE + 1);
        return registration;
    }

    @Bean
    public FilterRegistrationBean<GlobalRateLimitFilter> globalRateLimitFilter() {
        FilterRegistrationBean<GlobalRateLimitFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new GlobalRateLimitFilter());
        registration.addUrlPatterns("/api/v1/*");
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE + 2);
        return registration;
    }

    /**
     * Auth endpoints: 5 requests per minute per IP (login brute force protection)
     */
    public static class RateLimitFilter implements Filter {
        private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

        private Bucket createAuthBucket() {
            return Bucket.builder()
                    .addLimit(Bandwidth.classic(5, Refill.intervally(5, Duration.ofMinutes(1))))
                    .build();
        }

        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            HttpServletRequest httpReq = (HttpServletRequest) request;
            String ip = getClientIp(httpReq);
            Bucket bucket = buckets.computeIfAbsent(ip, k -> createAuthBucket());

            if (bucket.tryConsume(1)) {
                chain.doFilter(request, response);
            } else {
                HttpServletResponse httpRes = (HttpServletResponse) response;
                httpRes.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                httpRes.setContentType("application/json");
                httpRes.getWriter().write(
                        "{\"success\":false,\"message\":\"Quá nhiều yêu cầu. Vui lòng thử lại sau 1 phút.\",\"statusCode\":429}");
            }
        }
    }

    /**
     * Global: 100 requests per minute per IP
     */
    public static class GlobalRateLimitFilter implements Filter {
        private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

        private Bucket createGlobalBucket() {
            return Bucket.builder()
                    .addLimit(Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1))))
                    .build();
        }

        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
                throws IOException, ServletException {
            HttpServletRequest httpReq = (HttpServletRequest) request;
            String ip = getClientIp(httpReq);
            Bucket bucket = buckets.computeIfAbsent(ip, k -> createGlobalBucket());

            if (bucket.tryConsume(1)) {
                chain.doFilter(request, response);
            } else {
                HttpServletResponse httpRes = (HttpServletResponse) response;
                httpRes.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                httpRes.setContentType("application/json");
                httpRes.getWriter().write(
                        "{\"success\":false,\"message\":\"Quá nhiều yêu cầu. Vui lòng thử lại sau.\",\"statusCode\":429}");
            }
        }
    }

    private static String getClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isEmpty()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
