package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.order.dto.*;
import com.quyenauto.order.entity.Quotation;
import com.quyenauto.order.repository.QuotationRepository;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.repository.ProductRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class QuotationService {

    private final QuotationRepository quotationRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional(readOnly = true)
    public Page<QuotationResponse> getByCustomer(Long customerId, Pageable pageable) {
        return quotationRepository.findByCustomerId(customerId, pageable).map(QuotationResponse::from);
    }

    @Transactional(readOnly = true)
    public Page<QuotationResponse> getByStatus(String status, Pageable pageable) {
        Quotation.QuotationStatus qs = Quotation.QuotationStatus.valueOf(status.toUpperCase());
        return quotationRepository.findByStatus(qs, pageable).map(QuotationResponse::from);
    }

    @Transactional(readOnly = true)
    public Page<QuotationResponse> getAll(Pageable pageable) {
        return quotationRepository.findAll(pageable).map(QuotationResponse::from);
    }

    public Page<QuotationResponse> getPendingUncontacted(Pageable pageable) {
        return quotationRepository
                .findByStatusAndContactedFalse(Quotation.QuotationStatus.PENDING, pageable)
                .map(QuotationResponse::from);
    }

    public long countPendingUncontacted() {
        return quotationRepository.countByStatusAndContactedFalse(Quotation.QuotationStatus.PENDING);
    }

    @Transactional(readOnly = true)
    public QuotationResponse getById(Long id) {
        return QuotationResponse.from(findById(id));
    }

    @Transactional
    public QuotationResponse create(Long customerId, CreateQuotationRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));

        String optionsStr = request.getOptions() != null
                ? String.join(",", request.getOptions())
                : null;

        Quotation quotation = Quotation.builder()
                .customer(customer)
                .product(product)
                .weightRange(request.getWeightRange())
                .cargoType(request.getCargoType())
                .note(request.getNote())
                .vehicleBrand(request.getVehicleBrand())
                .bodyType(request.getBodyType())
                .bodySize(request.getBodySize())
                .lengthCm(request.getLengthCm())
                .widthCm(request.getWidthCm())
                .heightCm(request.getHeightCm())
                .options(optionsStr)
                .status(Quotation.QuotationStatus.PENDING)
                .build();

        Quotation saved = quotationRepository.save(quotation);

        notifyStaffNewQuotation(saved, customer, product);

        return QuotationResponse.from(saved);
    }

    @Transactional
    public QuotationResponse createGuest(GuestQuotationRequest request) {
        Product product = null;
        if (request.getProductId() != null) {
            product = productRepository.findById(request.getProductId()).orElse(null);
        }

        String optionsStr = request.getOptions() != null
                ? String.join(",", request.getOptions())
                : null;

        Quotation quotation = Quotation.builder()
                .guestPhone(request.getPhone())
                .guestName(request.getFullName())
                .product(product)
                .vehicleBrand(request.getVehicleBrand())
                .bodyType(request.getBodyType())
                .bodySize(request.getBodySize())
                .lengthCm(request.getLengthCm())
                .widthCm(request.getWidthCm())
                .heightCm(request.getHeightCm())
                .options(optionsStr)
                .note(request.getNote())
                .status(Quotation.QuotationStatus.PENDING)
                .build();

        Quotation saved = quotationRepository.save(quotation);

        notifyStaffGuestQuotation(saved);

        return QuotationResponse.from(saved);
    }

    @Transactional
    public QuotationResponse approve(Long id, Long staffId, QuoteApprovalRequest request) {
        Quotation quotation = findById(id);

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
    public QuotationResponse markContacted(Long id, Long staffId) {
        Quotation quotation = findById(id);

        if (quotation.getContacted()) {
            throw new BusinessException("Yêu cầu này đã được nhận xử lý");
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        quotation.setContacted(true);
        quotation.setContactedBy(staff);
        quotation.setContactedAt(LocalDateTime.now());

        Quotation saved = quotationRepository.save(quotation);

        messagingTemplate.convertAndSend(
                "/topic/staff/quotations",
                QuotationResponse.from(saved));

        return QuotationResponse.from(saved);
    }

    private void notifyStaffNewQuotation(Quotation quotation, User customer, Product product) {
        String title = "Yêu cầu báo giá mới";
        String body = customer.getFullName() + " - " + product.getName();
        if (quotation.getVehicleBrand() != null) {
            body += " (" + quotation.getVehicleBrand() + ")";
        }
        broadcastToStaff(title, body, quotation);
    }

    private void notifyStaffGuestQuotation(Quotation quotation) {
        String title = "Báo giá mới (khách vãng lai)";
        String name = quotation.getGuestName() != null ? quotation.getGuestName() : quotation.getGuestPhone();
        String body = name;
        if (quotation.getProduct() != null) {
            body += " - " + quotation.getProduct().getName();
        }
        broadcastToStaff(title, body, quotation);
    }

    private void broadcastToStaff(String title, String body, Quotation quotation) {
        String refId = quotation.getId().toString();

        List<User> staffMembers = userRepository.findByRoleInAndIsActiveTrue(
                List.of(UserRole.STAFF, UserRole.MANAGER, UserRole.ADMIN));

        for (User staff : staffMembers) {
            notificationService.createNotification(
                    staff.getId(), title, body, "NEW_QUOTATION", refId);
        }

        messagingTemplate.convertAndSend(
                "/topic/staff/quotations",
                QuotationResponse.from(quotation));
    }

    private Quotation findById(Long id) {
        return quotationRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu báo giá"));
    }
}
