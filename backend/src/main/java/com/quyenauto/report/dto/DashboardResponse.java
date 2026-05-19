package com.quyenauto.report.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class DashboardResponse {
    private long totalOrders;
    private long newOrders;          // PENDING orders (for stat card)
    private long inProduction;       // IN_PRODUCTION orders (for stat card)
    private long pendingQuotations;
    private long activeWarranties;   // PENDING + IN_PROGRESS warranties (for stat card)
    private BigDecimal totalRevenue;
    private BigDecimal monthlyRevenue;
    private List<MonthlyRevenue> revenueChart;

    @Data
    @Builder
    @AllArgsConstructor
    public static class MonthlyRevenue {
        private int month;
        private int year;
        private BigDecimal revenue;
    }
}
