package com.quyenauto.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
public class PaymentResponse {
    private String paymentUrl;
    private String transactionRef;
    private Long orderId;
    private BigDecimal amount;
    private String status;
}
