package com.quyenauto.payment.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.order.entity.Order;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.payment.dto.PaymentRequest;
import com.quyenauto.payment.dto.PaymentResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class VNPayService {

    private final OrderRepository orderRepository;

    @Value("${app.vnpay.tmn-code:}")
    private String tmnCode;

    @Value("${app.vnpay.hash-secret:}")
    private String hashSecret;

    @Value("${app.vnpay.pay-url:https://sandbox.vnpayment.vn/paymentv2/vpcpay.html}")
    private String payUrl;

    @Value("${app.vnpay.return-url:http://localhost:8080/api/v1/payment/callback}")
    private String returnUrl;

    private static final DateTimeFormatter VN_DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    public PaymentResponse createPayment(PaymentRequest request, String ipAddress) {
        if (tmnCode.isEmpty() || hashSecret.isEmpty()) {
            throw new BusinessException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Thanh toán VNPay chưa được cấu hình. Vui lòng liên hệ quản trị viên.");
        }

        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng"));

        if (order.getStatus() == Order.OrderStatus.CANCELLED) {
            throw new BusinessException("Không thể thanh toán đơn hàng đã hủy");
        }

        String txnRef = generateTransactionRef(order.getId());
        long amountInVND = request.getAmount().multiply(BigDecimal.valueOf(100)).longValue();

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(amountInVND));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", "Thanh toan don hang " + order.getOrderCode());
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", request.getReturnUrl() != null ? request.getReturnUrl() : returnUrl);
        params.put("vnp_IpAddr", ipAddress);
        params.put("vnp_CreateDate", LocalDateTime.now().format(VN_DATE_FMT));
        params.put("vnp_ExpireDate", LocalDateTime.now().plusMinutes(15).format(VN_DATE_FMT));

        if (request.getBankCode() != null && !request.getBankCode().isEmpty()) {
            params.put("vnp_BankCode", request.getBankCode());
        }

        String queryString = buildQueryString(params);
        String secureHash = hmacSHA512(hashSecret, queryString);
        String paymentUrl = payUrl + "?" + queryString + "&vnp_SecureHash=" + secureHash;

        log.info("VNPay payment URL created for order {} - txnRef: {}", order.getOrderCode(), txnRef);

        return PaymentResponse.builder()
                .paymentUrl(paymentUrl)
                .transactionRef(txnRef)
                .orderId(order.getId())
                .amount(request.getAmount())
                .status("PENDING")
                .build();
    }

    public boolean verifyCallback(Map<String, String> params) {
        String vnpSecureHash = params.get("vnp_SecureHash");
        if (vnpSecureHash == null) return false;

        Map<String, String> sorted = new TreeMap<>(params);
        sorted.remove("vnp_SecureHash");
        sorted.remove("vnp_SecureHashType");

        String queryString = buildQueryString(sorted);
        String calculated = hmacSHA512(hashSecret, queryString);

        return calculated.equalsIgnoreCase(vnpSecureHash);
    }

    public boolean isPaymentSuccess(Map<String, String> params) {
        return "00".equals(params.get("vnp_ResponseCode"));
    }

    private String generateTransactionRef(Long orderId) {
        return orderId + "_" + System.currentTimeMillis();
    }

    private String buildQueryString(Map<String, String> params) {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (sb.length() > 0) sb.append("&");
            sb.append(URLEncoder.encode(entry.getKey(), StandardCharsets.US_ASCII))
              .append("=")
              .append(URLEncoder.encode(entry.getValue(), StandardCharsets.US_ASCII));
        }
        return sb.toString();
    }

    private String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] result = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : result) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error generating HMAC", e);
        }
    }
}
