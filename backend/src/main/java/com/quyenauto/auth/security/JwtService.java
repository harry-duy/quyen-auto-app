package com.quyenauto.auth.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Slf4j
@Service
public class JwtService {

    private static final String DEFAULT_SECRET = "quyen-auto-default-jwt-secret-key-change-in-production-2024";

    private final SecretKey key;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.access-token-expiration}") long accessTokenExpiration,
            @Value("${app.jwt.refresh-token-expiration}") long refreshTokenExpiration,
            @Value("${spring.profiles.active:dev}") String activeProfile) {

        if ("prod".equalsIgnoreCase(activeProfile) && DEFAULT_SECRET.equals(secret)) {
            throw new IllegalStateException(
                    "JWT_SECRET must be configured via environment variable in production! " +
                    "Set JWT_SECRET env var with a strong random key (min 64 chars).");
        }

        if (secret.length() < 32) {
            throw new IllegalStateException("JWT secret must be at least 32 characters long.");
        }

        if (DEFAULT_SECRET.equals(secret)) {
            log.warn("⚠️ Using default JWT secret — acceptable for development only!");
        }

        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
    }

    public String generateAccessToken(Long userId, String role) {
        return buildToken(userId, role, accessTokenExpiration);
    }

    public String generateRefreshToken(Long userId) {
        return buildToken(userId, null, refreshTokenExpiration);
    }

    private String buildToken(Long userId, String role, long expiration) {
        Date now = new Date();
        JwtBuilder builder = Jwts.builder()
                .setSubject(String.valueOf(userId))
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + expiration))
                .signWith(key, SignatureAlgorithm.HS256);

        if (role != null) {
            builder.addClaims(Map.of("role", role));
        }
        return builder.compact();
    }

    public Long getUserIdFromToken(String token) {
        return Long.parseLong(parseClaims(token).getSubject());
    }

    public String getRoleFromToken(String token) {
        return parseClaims(token).get("role", String.class);
    }

    public boolean validateToken(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    private Claims parseClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public long getRefreshTokenExpiration() {
        return refreshTokenExpiration;
    }
}
