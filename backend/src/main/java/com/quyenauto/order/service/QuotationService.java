package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.order.dto.*;
import com.quyenauto.order.entity.Order;
import com.quyenauto.order.entity.OrderStatusLog;
import com.quyenauto.order.entity.Quotation;
import com.quyenauto.order.entity.QuotationOption;
import com.quyenauto.order.entity.QuotationSelectedOption;
import com.quyenauto.order.entity.QuotationTemplate;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.order.repository.QuotationOptionRepository;
import com.quyenauto.order.repository.QuotationRepository;
import com.quyenauto.order.repository.QuotationTemplateRepository;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.repository.ProductRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
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
    private final QuotationTemplateRepository quotationTemplateRepository;
    private final QuotationOptionRepository quotationOptionRepository;
    private final NotificationService notificationService;

    public Page<QuotationResponse> getByCustomer(Long customerId, Pageable pageable) {
        return quotationRepository.findByCustomerId(customerId, pageable).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getByStatus(String status, Pageable pageable) {
        Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
        return quotationRepository.findByStatus(qs, pageable).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getVisibleForStaff(Long staffId, String status, Pageable pageable) {
        User currentUser = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));
        boolean managerView = currentUser.getRole() == UserRole.MANAGER
                || currentUser.getRole() == UserRole.ADMIN;

        if (status != null) {
            Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
            if (isStaffCreatedStatus(qs)) {
                if (managerView) {
                    return quotationRepository.findStaffCreatedByStatus(qs, pageable)
                            .map(QuotationResponse::from);
                }
                return quotationRepository.findByStaffIdAndStatus(staffId, qs, pageable)
                        .map(QuotationResponse::from);
            }
            return quotationRepository.findVisibleByStatusForStaff(staffId, qs, pageable)
                    .map(QuotationResponse::from);
        }

        return quotationRepository.findDefaultVisibleForStaff(
                staffId,
                managerView,
                List.of(Quotation.QuotationStatus.PENDING, Quotation.QuotationStatus.QUOTED),
                pageable
        ).map(QuotationResponse::from);
    }

    /** Status thuộc flow NV tạo BG — chỉ visible cho NV đó (dùng `staff` field). */
    private static boolean isStaffCreatedStatus(Quotation.QuotationStatus qs) {
        return qs == Quotation.QuotationStatus.DRAFT
                || qs == Quotation.QuotationStatus.PENDING_APPROVAL
                || qs == Quotation.QuotationStatus.WAITING_TECHNICAL_REVIEW
                || qs == Quotation.QuotationStatus.NEED_REVISION
                || qs == Quotation.QuotationStatus.APPROVED
                || qs == Quotation.QuotationStatus.SENT
                || qs == Quotation.QuotationStatus.CONTRACT_PENDING
                || qs == Quotation.QuotationStatus.CUSTOMER_REJECTED;
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
    // Flow mới: NV tạo BG → Manager duyệt → NV liên hệ KH ngoài app
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * NV tạo báo giá cho khách hàng (flow mới).
     * BG tạo ra ở trạng thái DRAFT.
     */
    @Transactional
    public QuotationResponse staffCreateQuotation(Long staffId, StaffCreateQuotationRequest request) {
        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        // Khách có tài khoản hoặc khách vãng lai
        User customer = null;
        if (request.getCustomerId() != null) {
            customer = userRepository.findById(request.getCustomerId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy khách hàng"));
        } else if ((request.getGuestName() == null || request.getGuestName().isBlank())
                && (request.getGuestPhone() == null || request.getGuestPhone().isBlank())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Vui lòng chọn khách hàng hoặc nhập tên/SĐT khách vãng lai");
        }

        QuotationTemplate template = null;
        if (request.getTemplateId() != null) {
            template = quotationTemplateRepository.findById(request.getTemplateId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy mẫu báo giá"));
        }

        Product product = null;
        Boolean isNewProduct = Boolean.TRUE.equals(request.getIsNewProductRequest());

        if (!isNewProduct) {
            if (request.getProductId() == null && (template == null || template.getProduct() == null)) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "Vui lòng chọn sản phẩm hoặc chọn 'Sản phẩm mới'");
            }
            product = request.getProductId() != null
                    ? productRepository.findById(request.getProductId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"))
                    : template.getProduct();
        } else if (request.getNewProductDescription() == null || request.getNewProductDescription().isBlank()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Vui lòng mô tả yêu cầu sản phẩm mới");
        }

        Quotation quotation = Quotation.builder()
                .customer(customer)
                .guestName(request.getGuestName())
                .guestPhone(request.getGuestPhone())
                .quotationTemplate(template)
                .product(product)
                .staff(staff)
                .vehicleModel(firstNonBlank(request.getVehicleModel(), template != null ? template.getVehicleModel() : null))
                .quantity(request.getQuantity() != null ? request.getQuantity() : 1)
                .chassisWidth(request.getChassisWidth() != null ? request.getChassisWidth() : template != null ? template.getChassisWidth() : null)
                .boxCode(request.getBoxCode())
                .boxType(firstNonBlank(request.getBoxType(), template != null ? template.getBoxType() : null))
                .acType(firstNonBlank(request.getAcType(), template != null ? template.getAcType() : null))
                .acModel(firstNonBlank(request.getAcModel(), template != null ? template.getAcModel() : null))
                .innerWallInsulated(request.getInnerWallInsulated())
                .specifications(firstNonBlank(request.getSpecifications(), template != null ? template.getSpecifications() : null))
                .weightRange(request.getWeightRange())
                .cargoType(request.getCargoType())
                .note(request.getNote())
                .isStaffCreated(true)
                .isNewProductRequest(isNewProduct)
                .newProductDescription(request.getNewProductDescription())
                .status(Quotation.QuotationStatus.DRAFT)
                .build();

        BigDecimal basePrice = template != null && template.getBasePrice() != null
                ? template.getBasePrice()
                : BigDecimal.ZERO;
        List<QuotationSelectedOption> selectedOptions = buildSelectedOptions(quotation, request.getSelectedOptions());
        BigDecimal optionTotal = selectedOptions.stream()
                .map(QuotationSelectedOption::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal estimatedTotal = basePrice.add(optionTotal);

        quotation.setBasePrice(basePrice);
        quotation.setOptionTotal(optionTotal);
        quotation.setEstimatedTotal(estimatedTotal);
        quotation.setQuotedPrice(estimatedTotal);
        quotation.getSelectedOptions().clear();
        quotation.getSelectedOptions().addAll(selectedOptions);

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
        if (quotation.getStatus() != Quotation.QuotationStatus.DRAFT
                && quotation.getStatus() != Quotation.QuotationStatus.NEED_REVISION) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể gửi duyệt báo giá đang ở trạng thái DRAFT");
        }

        quotation.setStatus(Quotation.QuotationStatus.PENDING_APPROVAL);
        quotation.setRevisionNote(null);
        Quotation saved = quotationRepository.save(quotation);

        // Thông báo đến Manager
        notificationService.notifyAllManagers(
                "Báo giá chờ duyệt",
                (quotation.getStaff().getFullName()) + " đã gửi báo giá #" + id + " chờ duyệt cho KH " + (quotation.getCustomer() != null ? quotation.getCustomer().getFullName() : quotation.getGuestName()),
                "QUOTATION_APPROVAL_REQUEST",
                id.toString()
        );

        return QuotationResponse.from(saved);
    }

    @Transactional
    public QuotationResponse managerRequestRevision(Long id, Long managerId, ManagerApprovalRequest request) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING_APPROVAL
                && quotation.getStatus() != Quotation.QuotationStatus.WAITING_TECHNICAL_REVIEW) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chi co the tra lai bao gia dang cho duyet hoac cho ky thuat");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay manager"));

        quotation.setApprovedBy(manager);
        quotation.setApprovedAt(LocalDateTime.now());
        quotation.setRevisionNote(firstNonBlank(request.getRevisionNote(), request.getManagerNote()));
        quotation.setStaffNote(request.getManagerNote());
        quotation.setStatus(Quotation.QuotationStatus.NEED_REVISION);
        Quotation saved = quotationRepository.save(quotation);

        if (quotation.getStaff() != null) {
            notificationService.createNotification(
                    quotation.getStaff().getId(),
                    "Bao gia can bo sung",
                    "Manager tra lai bao gia #" + id
                            + (quotation.getRevisionNote() != null ? ": " + quotation.getRevisionNote() : ""),
                    "QUOTATION_NEED_REVISION",
                    id.toString()
            );
        }

        return QuotationResponse.from(saved);
    }

    @Transactional
    public QuotationResponse managerMarkTechnicalReview(Long id, Long managerId, ManagerApprovalRequest request) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.PENDING_APPROVAL) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chi co the dua bao gia dang cho duyet sang cho ky thuat");
        }

        User manager = userRepository.findById(managerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay manager"));

        quotation.setApprovedBy(manager);
        quotation.setApprovedAt(LocalDateTime.now());
        quotation.setTechnicalNote(firstNonBlank(request.getTechnicalNote(), request.getManagerNote()));
        quotation.setStaffNote(request.getManagerNote());
        quotation.setStatus(Quotation.QuotationStatus.WAITING_TECHNICAL_REVIEW);
        Quotation saved = quotationRepository.save(quotation);

        if (quotation.getStaff() != null) {
            notificationService.createNotification(
                    quotation.getStaff().getId(),
                    "Bao gia cho ky thuat xac nhan",
                    "Manager tam giu bao gia #" + id + " de xac nhan ky thuat",
                    "QUOTATION_TECHNICAL_REVIEW",
                    id.toString()
            );
        }

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

        BigDecimal adjustmentFee = zeroIfNull(request.getAdjustmentFee());
        BigDecimal discountAmount = zeroIfNull(request.getDiscountAmount());
        BigDecimal approvedTotal = request.getApprovedTotal() != null
                ? request.getApprovedTotal()
                : quotation.getEstimatedTotal().add(adjustmentFee).subtract(discountAmount);

        quotation.setApprovedBy(manager);
        quotation.setApprovedAt(LocalDateTime.now());
        quotation.setStaffNote(request.getManagerNote());
        quotation.setAdjustmentFee(adjustmentFee);
        quotation.setDiscountAmount(discountAmount);
        quotation.setApprovedTotal(approvedTotal);
        quotation.setQuotedPrice(approvedTotal);
        quotation.setPriceNote(blankToNull(request.getPriceNote()));
        quotation.setTechnicalNote(blankToNull(request.getTechnicalNote()));
        quotation.setStatus(Quotation.QuotationStatus.APPROVED);
        Quotation saved = quotationRepository.save(quotation);

        // Thông báo NV
        if (quotation.getStaff() != null) {
            notificationService.createNotification(
                    quotation.getStaff().getId(),
                    "Báo giá đã được duyệt",
                    "Manager đã duyệt báo giá #" + id + " cho KH " + (quotation.getCustomer() != null ? quotation.getCustomer().getFullName() : quotation.getGuestName()),
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
     * NV đánh dấu đã liên hệ và trao đổi báo giá với KH ngoài app.
     * APPROVED → SENT
     */
    @Transactional
    public QuotationResponse staffSendToCustomer(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.APPROVED) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể đánh dấu đã liên hệ sau khi Manager duyệt báo giá");
        }
        if (quotation.getStaff() == null || !quotation.getStaff().getId().equals(staffId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền thao tác báo giá này");
        }

        quotation.setSentAt(LocalDateTime.now());
        quotation.setStatus(Quotation.QuotationStatus.SENT);

        // Báo giá là dữ liệu nội bộ staff/manager. KH được liên hệ ngoài app,
        // không nhận notification báo giá để tránh hiểu rằng giá đã hiển thị trong app.

        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    /**
     * NV xác nhận khách đã đồng ý báo giá.
     * SENT → CONTRACT_PENDING
     */
    @Transactional
    public QuotationResponse staffConfirmCustomerAgreed(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.SENT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể xác nhận KH đồng ý sau khi đã liên hệ khách");
        }
        if (quotation.getStaff() == null || !quotation.getStaff().getId().equals(staffId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền thao tác báo giá này");
        }

        quotation.setStatus(Quotation.QuotationStatus.CONTRACT_PENDING);
        return QuotationResponse.from(quotationRepository.save(quotation));
    }

    /**
     * NV ghi nhận khách từ chối báo giá.
     * SENT → CUSTOMER_REJECTED
     */
    @Transactional
    public QuotationResponse staffMarkCustomerRejected(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (quotation.getStatus() != Quotation.QuotationStatus.SENT) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Chỉ có thể ghi nhận KH từ chối sau khi đã liên hệ khách");
        }
        if (quotation.getStaff() == null || !quotation.getStaff().getId().equals(staffId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền thao tác báo giá này");
        }

        quotation.setStatus(Quotation.QuotationStatus.CUSTOMER_REJECTED);
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

    private String firstNonBlank(String primary, String fallback) {
        return primary != null && !primary.isBlank() ? primary : fallback;
    }

    private List<QuotationSelectedOption> buildSelectedOptions(
            Quotation quotation,
            List<SelectedQuotationOptionRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return new ArrayList<>();
        }

        List<QuotationSelectedOption> options = new ArrayList<>();
        for (SelectedQuotationOptionRequest request : requests) {
            if (request == null) continue;
            int quantity = request.getQuantity() != null && request.getQuantity() > 0
                    ? request.getQuantity()
                    : 1;

            QuotationOption catalogOption = null;
            String name = blankToNull(request.getName());
            String position = blankToNull(request.getPosition());
            String unit = blankToNull(request.getUnit());
            BigDecimal unitPrice = request.getUnitPrice();
            boolean isCustom = request.getOptionId() == null || Boolean.TRUE.equals(request.getIsCustom());

            if (request.getOptionId() != null) {
                catalogOption = quotationOptionRepository.findById(request.getOptionId())
                        .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay option bao gia"));
                if (!Boolean.TRUE.equals(catalogOption.getIsActive())) {
                    throw new BusinessException(HttpStatus.BAD_REQUEST, "Option bao gia da bi tat: " + catalogOption.getName());
                }
                name = catalogOption.getName();
                position = catalogOption.getPosition();
                unit = catalogOption.getUnit();
                unitPrice = catalogOption.getDefaultPrice();
                isCustom = false;
            }

            if (name == null) {
                throw new BusinessException(HttpStatus.BAD_REQUEST, "Vui long nhap ten option ngoai danh muc");
            }
            if (position == null) {
                position = "OTHER";
            }
            if (unit == null) {
                unit = "cai";
            }
            if (unitPrice == null) {
                unitPrice = BigDecimal.ZERO;
            }

            BigDecimal total = unitPrice.multiply(BigDecimal.valueOf(quantity));
            options.add(QuotationSelectedOption.builder()
                    .quotation(quotation)
                    .option(catalogOption)
                    .nameSnapshot(name)
                    .positionSnapshot(position.toUpperCase())
                    .unitSnapshot(unit)
                    .unitPriceSnapshot(unitPrice)
                    .quantity(quantity)
                    .totalPrice(total)
                    .note(blankToNull(request.getNote()))
                    .isCustom(isCustom)
                    .build());
        }
        return options;
    }

    private BigDecimal zeroIfNull(BigDecimal value) {
        return value != null ? value : BigDecimal.ZERO;
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
