package com.quyenauto.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SendMessageRequest {

    @NotNull(message = "Room ID không được để trống")
    private Long roomId;

    @NotBlank(message = "Nội dung không được để trống")
    private String content;

    private String type = "TEXT";
}
