package com.quyenauto.payment.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.order.entity.Order;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.payment.dto.PaymentRequest;
import com.quyenauto.payment.dto.PaymentResponse;
import com.quyenauto.payment.service.VNPayService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/payment")
@RequiredArgsConstructor
@Tag(name = "Payment", description = "Thanh toán VNPay")
public class PaymentController {

    private final VNPayService vnPayService;
    private final OrderRepository orderRepository;

    @PostMapping("/create")
    @Operation(summary = "Tạo URL thanh toán VNPay")
    public ResponseEntity<ApiResponse<PaymentResponse>> createPayment(
            @Valid @RequestBody PaymentRequest request,
            HttpServletRequest httpRequest) {
        String ipAddress = getClientIp(httpRequest);
        PaymentResponse response = vnPayService.createPayment(request, ipAddress);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/callback")
    @Operation(summary = "VNPay callback (redirect sau thanh toán)")
    public ResponseEntity<ApiResponse<Map<String, String>>> paymentCallback(
            @RequestParam Map<String, String> params) {

        boolean valid = vnPayService.verifyCallback(params);
        if (!valid) {
            log.warn("VNPay callback with invalid signature: {}", params);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, "Chữ ký không hợp lệ"));
        }

        boolean success = vnPayService.isPaymentSuccess(params);
        String txnRef = params.get("vnp_TxnRef");

        if (success && txnRef != null) {
            try {
                long orderId = Long.parseLong(txnRef.split("_")[0]);
                orderRepository.findById(orderId).ifPresent(order -> {
                    if (order.getStatus() == Order.OrderStatus.PENDING) {
                        order.setStatus(Order.OrderStatus.CONFIRMED);
                        orderRepository.save(order);
                        log.info("Payment successful for order {}, status updated to CONFIRMED", order.getOrderCode());
                    }
                });
            } catch (NumberFormatException e) {
                log.error("Invalid txnRef format: {}", txnRef);
            }
        }

        Map<String, String> result = Map.of(
                "status", success ? "SUCCESS" : "FAILED",
                "transactionRef", txnRef != null ? txnRef : "",
                "responseCode", params.getOrDefault("vnp_ResponseCode", "99")
        );

        return ResponseEntity.ok(ApiResponse.ok(result));
    }

    private String getClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isEmpty()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
