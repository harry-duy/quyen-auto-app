package com.quyenauto.config;

import com.quyenauto.auth.security.CustomUserDetailsService;
import com.quyenauto.auth.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtService jwtService;
    private final CustomUserDetailsService userDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = extractToken(accessor);
            if (token == null || !jwtService.validateToken(token)) {
                log.warn("WebSocket CONNECT rejected — missing or invalid JWT");
                throw new IllegalArgumentException("Unauthorized WebSocket connection");
            }
            Long userId = jwtService.getUserIdFromToken(token);
            UserDetails userDetails = userDetailsService.loadUserById(userId);
            UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities());
            accessor.setUser(auth);
        }

        return message;
    }

    private String extractToken(StompHeaderAccessor accessor) {
        String header = accessor.getFirstNativeHeader("Authorization");
        if (StringUtils.hasText(header) && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }
}
