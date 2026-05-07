package com.quyenauto.report.service;

import com.quyenauto.order.entity.Order;
import com.quyenauto.order.entity.Quotation;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.order.repository.QuotationRepository;
import com.quyenauto.report.dto.DashboardResponse;
import com.quyenauto.warranty.entity.WarrantyRequest;
import com.quyenauto.warranty.repository.WarrantyRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final OrderRepository orderRepository;
    private final QuotationRepository quotationRepository;
    private final WarrantyRequestRepository warrantyRepository;

    public DashboardResponse getDashboard() {
        long totalOrders = orderRepository.count();
        long pendingOrders = orderRepository.countByStatus(Order.OrderStatus.PENDING);
        long pendingQuotations = quotationRepository.countByStatus(Quotation.QuotationStatus.PENDING);
        long pendingWarranties = warrantyRepository.countByStatus(WarrantyRequest.WarrantyStatus.PENDING);

        var totalRevenue = orderRepository.sumRevenueByStatus(Order.OrderStatus.COMPLETED);

        LocalDate now = LocalDate.now();
        var monthlyRevenue = orderRepository.sumMonthlyRevenueByStatus(Order.OrderStatus.COMPLETED, now.getMonthValue(), now.getYear());

        List<DashboardResponse.MonthlyRevenue> revenueChart = new ArrayList<>();
        for (int i = 5; i >= 0; i--) {
            LocalDate month = now.minusMonths(i);
            var rev = orderRepository.sumMonthlyRevenueByStatus(Order.OrderStatus.COMPLETED, month.getMonthValue(), month.getYear());
            revenueChart.add(DashboardResponse.MonthlyRevenue.builder()
                    .month(month.getMonthValue())
                    .year(month.getYear())
                    .revenue(rev)
                    .build());
        }

        return DashboardResponse.builder()
                .totalOrders(totalOrders)
                .pendingOrders(pendingOrders)
                .pendingQuotations(pendingQuotations)
                .pendingWarranties(pendingWarranties)
                .totalRevenue(totalRevenue)
                .monthlyRevenue(monthlyRevenue)
                .revenueChart(revenueChart)
                .build();
    }
}
