package com.quyenauto.chat.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomResponse {
    private Long id;
    private Long customerId;
    private String customerName;
    private String customerAvatar;
    private Long staffId;
    private String staffName;
    private String staffAvatar;
    private String orderCode;
    /** true khi chưa có staff tiếp nhận (staffId == null). */
    @JsonProperty("isWaiting")
    private boolean isWaiting;
    private String lastMessage;
    private LocalDateTime lastMessageAt;
    private Long unreadCount;
}
