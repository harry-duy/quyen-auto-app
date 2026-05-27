package com.quyenauto.chat.dto;

import com.quyenauto.chat.entity.ChatMessage;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageResponse {
    private Long id;
    private Long roomId;
    private Long senderId;
    private String senderName;
    private String senderAvatar;
    private String content;
    private String type;
    private Boolean isRead;
    private LocalDateTime createdAt;

    public static ChatMessageResponse from(ChatMessage m) {
        return ChatMessageResponse.builder()
                .id(m.getId())
                .roomId(m.getRoom().getId())
                .senderId(m.getSender().getId())
                .senderName(m.getSender().getFullName())
                .senderAvatar(m.getSender().getAvatarUrl())
                .content(m.getContent())
                .type(m.getType().name())
                .isRead(m.getIsRead())
                .createdAt(m.getCreatedAt())
                .build();
    }
}
