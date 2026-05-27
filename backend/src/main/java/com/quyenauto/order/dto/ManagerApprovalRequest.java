package com.quyenauto.order.dto;

import lombok.Data;

/**
 * Request khi Manager duyệt hoặc từ chối báo giá.
 */
@Data
public class ManagerApprovalRequest {

    /** Ghi chú của Manager (lý do duyệt hoặc từ chối) */
    private String managerNote;
}
