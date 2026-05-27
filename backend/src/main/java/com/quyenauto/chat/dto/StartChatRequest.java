package com.quyenauto.chat.dto;

import lombok.Data;

@Data
public class StartChatRequest {
    /** Mã hợp đồng / đơn hàng đính kèm (tuỳ chọn). */
    private String orderCode;
    /** Tin nhắn đầu tiên gửi kèm khi mở chat. */
    private String firstMessage;
}
