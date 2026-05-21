package com.quyenauto.chat.dto;

import lombok.Data;

@Data
public class TypingMessage {
    private Long roomId;
    private boolean typing;
}
