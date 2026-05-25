package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.order.dto.*;
import com.quyenauto.order.entity.Order;
import com.quyenauto.order.entity.OrderStatusLog;
import com.quyenauto.order.entity.Quotation;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.order.repository.QuotationRepository;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.repository.ProductRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuotationService {

    private final QuotationRepository quotationRepository;
    private final OrderRepository orderRepository;
    private final OrderService orderService;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final NotificationService notificationService;

    public Page<QuotationResponse> getByCustomer(Long customerId, Pageable pageable) {
        return quotationRepository.findByCustomerId(customerId, pageable).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getByStatus(String status, Pageable pageable) {
        Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
        return quotationRepository.findByStatus(qs, pageable).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getVisibleForStaff(Long staffId, String status, Pageable pageable) {
        if (status != null) {
            Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
            return quotationRepository.findVisibleByStatusForStaff(staffId, qs, pageable)
                    .map(QuotationResponse::from);
        }

        return quotationRepository.findVisibleActiveForStaff(
                staffId,
                List.of(Quotation.QuotationStatus.PENDING, Quotation.QuotationStatus.QUOTED),
                pageable
        ).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getAll(Pageable pageable) {
        return quotationRepository.findAll(pageable).map(QuotationResponse::from);
    }

    public QuotationResponse getById(Long id) {
        return QuotationResponse.from(findById(id));
    }

    @Transactional
    public QuotationResponse create(Long customerId, CreateQuotationRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));

        Quotation quotation = Quotation.builder()
                .customer(customer)
                .product(product)
                .vehicleModel(request.getVehicleModel())
                .quantity(request.getQuantity() != null ? request.getQuantity() : 1)
                .chassisWidth(request.getChassisWidth())
                .boxCode(request.getBoxCode())
                .boxType(request.getBoxType())
                .acType(request.getAcType())
                .acModel(request.getAcModel())
                .innerWallInsulated(request.getInnerWallInsulated())
                .specifications(request.getSpecifications())
                .weightRange(request.getWeightRange())
                .cargoType(request.getCargoType())
                .note(request.getNote())
                .status(Quotation.QuotationStatus.PENDING)
                .build();

        Quotation saved = quotationRepository.save(quotation);

        // Gửi thông báo đến tất cả STAFF và MANAGER (kèm số điện thoại)
        String vehicleInfo = request.getVehicleModel() != null ? request.getVehicleModel() : product.getName();
        notificationService.notifyAllStaff(
                "Yêu cầu báo giá mới",
                customer.getFullName() + " (" + customer.getPhone() + ") yêu cầu báo giá: " + vehicleInfo,
                "QUOTATION_NEW",
                saved.getId().toString()
        );

        return QuotationResponse.from(saved);
    }

    @Transactional
    public QuotationResponse markContacted(Long id, Long staffId) {
        Quotation quotation = findById(id);
        // Nếu đã có người liên hệ rồi thì giữ nguyên
        if (quotation.getContactedAt() != null) {
            if (quotation.getContactedBy() != null && !quotation.getContactedBy().getId().equals(staffId)) {
                throw new BusinessException("Bao gia nay da co nhan vien khac nhan xu ly");
            }
            return QuotationResponse.from(quotation);
        }
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));
        quotation.setContactedBy(staff);
        quotation.setContactedAt(LocalDateTime.now());
        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    @Transactional
    public QuotationResponse approve(Long id, Long staffId, QuoteApprovalRequest request) {
        Quotation quotation = findById(id);
        ensureNotOwnedByAnotherStaff(quotation, staffId);

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING) {
            throw new BusinessException("Chỉ có thể báo giá cho yêu cầu đang chờ");
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        quotation.setQuotedPrice(request.getQuotedPrice());
        quotation.setStaffNote(request.getStaffNote());
        quotation.setStaff(staff);
        quotation.setStatus(Quotation.QuotationStatus.QUOTED);

        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    @Transactional
    public OrderResponse confirmOrder(Long id, Long staffId, ConfirmQuotationOrderRequest request) {
        Quotation quotation = findById(id);
        ensureNotOwnedByAnotherStaff(quotation, staffId);

        if (quotation.getStatus() == Quotation.QuotationStatus.ACCEPTED) {
            return orderRepository.findByQuotationId(id)
                    .map(OrderResponse::from)
                    .orElseThrow(() -> new BusinessException("Bao gia da chot nhung chua co don hang lien ket"));
        }

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING
                && quotation.getStatus() != Quotation.QuotationStatus.QUOTED) {
            throw new BusinessException("Chi co the chot bao gia dang cho hoac da bao gia");
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay nhan vien"));

        Product product = quotation.getProduct();
        String note = request.getStaffNote();

        quotation.setQuotedPrice(request.getQuotedPrice());
        quotation.setStaff(staff);
        quotation.setStaffNote(note);
        quotation.setStatus(Quotation.QuotationStatus.ACCEPTED);

        Order order = Order.builder()
                .orderCode(orderService.generateOrderCode())
                .quotation(quotation)
                .customer(quotation.getCustomer())
                .product(product)
                .productName(product != null ? product.getName() : quotation.getVehicleModel())
                .totalAmount(request.getQuotedPrice())
                .depositAmount(request.getDepositAmount() != null ? request.getDepositAmount() : java.math.BigDecimal.ZERO)
                .status(Order.OrderStatus.CONFIRMED)
                .productionStatus("ORDER_CONFIRMED")
                .note(note)
                .estimatedDate(request.getEstimatedDate())
                .assignedStaff(staff)
                .build();

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(Order.OrderStatus.CONFIRMED.name())
                .note("Chot bao gia va tao don hang")
                .changedBy(staff)
                .build();
        order.getStatusLogs().add(log);

        Order saved = orderRepository.save(order);
        quotationRepository.save(quotation);

        notificationService.createNotification(
                quotation.getCustomer().getId(),
                "Don hang da duoc xac nhan",
                "Bao gia cua ban da duoc chot thanh don hang " + saved.getOrderCode(),
                "ORDER_CONFIRMED",
                saved.getId().toString()
        );

        return OrderResponse.from(saved);
    }

    private Quotation findById(Long id) {
        return quotationRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu báo giá"));
    }

    private void ensureNotOwnedByAnotherStaff(Quotation quotation, Long staffId) {
        if (quotation.getContactedBy() != null && !quotation.getContactedBy().getId().equals(staffId)) {
            throw new BusinessException("Bao gia nay da co nhan vien khac nhan xu ly");
        }
    }
}
