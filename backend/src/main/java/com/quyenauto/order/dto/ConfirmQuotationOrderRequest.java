package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ConfirmQuotationOrderRequest {

    @NotNull(message = "Gia chot khong duoc de trong")
    @PositiveOrZero(message = "Gia chot phai lon hon hoac bang 0")
    private BigDecimal quotedPrice;

    @PositiveOrZero(message = "Tien coc phai lon hon hoac bang 0")
    private BigDecimal depositAmount;

    private LocalDate estimatedDate;

    private String staffNote;
}
