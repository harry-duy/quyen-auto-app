package com.quyenauto.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.quyenauto.common.dto.ApiResponse;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Rate limit cho POST /auth/login:
 * - Toi da 5 lan thu / IP / 15 phut.
 * - Dung in-memory Bucket4j — khong can Redis.
 * - Tra ve 429 Too Many Requests neu vuot qua gioi han.
 */
@Component
@Order(1)
@RequiredArgsConstructor
public class LoginRateLimitFilter extends OncePerRequestFilter {

    private static final int    MAX_ATTEMPTS  = 5;
    private static final Duration REFILL_PERIOD = Duration.ofMinutes(15);
    private static final String LOGIN_PATH    = "/auth/login";

    private final ObjectMapper objectMapper;
    private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        // Chi ap dung cho POST /auth/login
        if (!HttpMethod.POST.matches(request.getMethod())
                || !LOGIN_PATH.equals(request.getServletPath())) {
            filterChain.doFilter(request, response);
            return;
        }

        String ip = extractClientIp(request);
        Bucket bucket = buckets.computeIfAbsent(ip, this::createBucket);

        if (bucket.tryConsume(1)) {
            filterChain.doFilter(request, response);
        } else {
            writeTooManyRequests(response);
        }
    }

    private Bucket createBucket(String ip) {
        Bandwidth limit = Bandwidth.classic(
                MAX_ATTEMPTS,
                Refill.intervally(MAX_ATTEMPTS, REFILL_PERIOD)
        );
        return Bucket.builder().addLimit(limit).build();
    }

    /** Lay IP that cua client, co xu ly reverse-proxy. */
    private String extractClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            // "X-Forwarded-For: client, proxy1, proxy2" — lay phan tu dau
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private void writeTooManyRequests(HttpServletResponse response) throws IOException {
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        ApiResponse<Void> body = ApiResponse.error(429,
                "Qua nhieu lan dang nhap that bai. Vui long thu lai sau 15 phut.");
        objectMapper.writeValue(response.getWriter(), body);
    }
}
