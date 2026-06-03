package com.quyenauto.order.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ManagerApprovalRequest {
    private String managerNote;
    private BigDecimal adjustmentFee;
    private BigDecimal discountAmount;
    private BigDecimal approvedTotal;
    private String priceNote;
    private String technicalNote;
    private String revisionNote;
}
