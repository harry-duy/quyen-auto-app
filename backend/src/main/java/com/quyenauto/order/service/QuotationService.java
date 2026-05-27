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
            // Staff-created flow statuses: chỉ hiện BG của chính NV đó tạo ra.
            // Dùng field `staff` thay vì `contactedBy` vì staff-created BG không có contactedBy.
            if (isStaffCreatedStatus(qs)) {
                return quotationRepository.findByStaffIdAndStatus(staffId, qs, pageable)
                        .map(QuotationResponse::from);
            }
            return quotationRepository.findVisibleByStatusForStaff(staffId, qs, pageable)
                    .map(QuotationResponse::from);
        }

        return quotationRepository.findVisibleActiveForStaff(
                staffId,
                List.of(Quotation.QuotationStatus.PENDING, Quotation.QuotationStatus.QUOTED),
                pageable
        ).map(QuotationResponse::from);
    }

    /** Status thuộc flow NV tạo BG — chỉ visible cho NV đó (dùng `staff` field). */
    private static boolean isStaffCreatedStatus(Quotation.QuotationStatus qs) {
        return qs == Quotation.QuotationStatus.DRAFT
                || qs == Quotation.QuotationStatus.PENDING_APPROVAL
                || qs == Quotation.QuotationStatus.APPROVED
                || qs == Quotation.QuotationStatus.SENT;
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

    // ─────────────────────────────────────────────────────────────────────────
    // Flow mới: NV tạo BG → Manager duyệt → NV gửi KH
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * NV tạo báo giá cho khách hàng (flow mới).
     * BG tạo ra ở trạng thái DRAFT.
     */
    @Transactional
    public QuotationResponse staffCreateQuotation(Long staffId, StaffCreateQuotationRequest request) {
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        User customer = userRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy khách hàng"));

        Product product = null;
        Boolean isNewProduct = Boolean.TRUE.equals(request.getIsNewProductRequest());

        if (!isNewProduct) {
            if (request.getProductId() == null) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "Vui lòng chọn sản phẩm hoặc chọn 'Sản phẩm mới'");
            }
            product = productRepository.findById(request.getProductId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));
        } else if (request.getNewProductDescription() == null || request.getNewProductDescription().isBlank()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Vui lòng mô tả yêu cầu sản phẩm mới");
        }

        Quotation quotation = Quotation.builder()
                .customer(customer)
                .product(product)
                .staff(staff)
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
                .isStaffCreated(true)
                .isNewProductRequest(isNewProduct)
                .newProductDescription(request.getNewProductDescription())
                .status(Quotation.QuotationStatus.DRAFT)
                .build();

        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    /**
     * NV gửi BG chờ Manager duyệt.
     * DRAFT → PENDING_APPROVAL
     */
    @Transactional
    public QuotationResponse submitForApproval(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (!Boolean.TRUE.equals(quotation.getIsStaffCreated())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ áp dụng cho báo giá do NV tạo");
        }
        if (quotation.getStaff() == null || !quotation.getStaff().getId().equals(staffId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền thao tác báo giá này");
        }
        if (quotation.getStatus() != Quotation.QuotationStatus.DRAFT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể gửi duyệt báo giá đang ở trạng thái DRAFT");
        }

        quotation.setStatus(Quotation.QuotationStatus.PENDING_APPROVAL);
        Quotation saved = quotationRepository.save(quotation);

        // Thông báo đến Manager
        notificationService.notifyAllManagers(
                "Báo giá chờ duyệt",
                (quotation.getStaff().getFullName()) + " đã gửi báo giá #" + id + " cho KH " + quotation.getCustomer().getFullName(),
                "QUOTATION_APPROVAL_REQUEST",
                id.toString()
        );

        return QuotationResponse.from(saved);
    }

    /**
     * Manager duyệt báo giá.
     * PENDING_APPROVAL → APPROVED
     */
    @Transactional
    public QuotationResponse managerApproveQuotation(Long id, Long managerId, ManagerApprovalRequest request) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING_APPROVAL) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể duyệt báo giá đang chờ xác nhận");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy manager"));

        quotation.setApprovedBy(manager);
        quotation.setApprovedAt(LocalDateTime.now());
        quotation.setStaffNote(request.getManagerNote());
        quotation.setStatus(Quotation.QuotationStatus.APPROVED);
        Quotation saved = quotationRepository.save(quotation);

        // Thông báo NV
        if (quotation.getStaff() != null) {
            notificationService.createNotification(
                    quotation.getStaff().getId(),
                    "Báo giá đã được duyệt",
                    "Manager đã duyệt báo giá #" + id + " cho KH " + quotation.getCustomer().getFullName(),
                    "QUOTATION_APPROVED",
                    id.toString()
            );
        }

        return QuotationResponse.from(saved);
    }

    /**
     * Manager từ chối báo giá.
     * PENDING_APPROVAL → REJECTED
     */
    @Transactional
    public QuotationResponse managerRejectQuotation(Long id, Long managerId, ManagerApprovalRequest request) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING_APPROVAL) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể từ chối báo giá đang chờ xác nhận");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy manager"));

        quotation.setApprovedBy(manager);
        quotation.setApprovedAt(LocalDateTime.now());
        quotation.setStaffNote(request.getManagerNote());
        quotation.setStatus(Quotation.QuotationStatus.REJECTED);
        Quotation saved = quotationRepository.save(quotation);

        // Thông báo NV
        if (quotation.getStaff() != null) {
            notificationService.createNotification(
                    quotation.getStaff().getId(),
                    "Báo giá bị từ chối",
                    "Manager từ chối báo giá #" + id
                            + (request.getManagerNote() != null ? ": " + request.getManagerNote() : ""),
                    "QUOTATION_REJECTED",
                    id.toString()
            );
        }

        return QuotationResponse.from(saved);
    }

    /**
     * NV đánh dấu đã gửi BG cho KH.
     * APPROVED → SENT
     */
    @Transactional
    public QuotationResponse staffSendToCustomer(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.APPROVED) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể gửi báo giá đã được Manager duyệt");
        }
        if (quotation.getStaff() == null || !quotation.getStaff().getId().equals(staffId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền thao tác báo giá này");
        }

        quotation.setSentAt(LocalDateTime.now());
        quotation.setStatus(Quotation.QuotationStatus.SENT);

        // Thông báo KH
        notificationService.createNotification(
                quotation.getCustomer().getId(),
                "Báo giá đã được gửi",
                "Nhân viên Quyen Auto đã gửi báo giá cho bạn. Vui lòng kiểm tra.",
                "QUOTATION_SENT",
                id.toString()
        );

        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    /** DS BG chờ Manager duyệt */
    public Page<QuotationResponse> getPendingApproval(Pageable pageable) {
        return quotationRepository.findByStatusOrderByCreatedAtDesc(
                Quotation.QuotationStatus.PENDING_APPROVAL, pageable
        ).map(QuotationResponse::from);
    }

    /** DS BG do NV tạo — có filter status */
    public Page<QuotationResponse> getStaffCreatedQuotations(String status, Pageable pageable) {
        if (status != null) {
            Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
            return quotationRepository.findStaffCreatedByStatus(qs, pageable).map(QuotationResponse::from);
        }
        return quotationRepository.findStaffCreatedByStatus(null, pageable).map(QuotationResponse::from);
    }

    // ─────────────────────────────────────────────────────────────────────────

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
