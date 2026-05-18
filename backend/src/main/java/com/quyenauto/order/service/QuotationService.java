package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.notification.service.NotificationService;
import com.quyenauto.order.dto.*;
import com.quyenauto.order.entity.Quotation;
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

@Service
@RequiredArgsConstructor
public class QuotationService {

    private final QuotationRepository quotationRepository;
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

        // Gửi thông báo đến tất cả STAFF và MANAGER
        String vehicleInfo = request.getVehicleModel() != null ? request.getVehicleModel() : product.getName();
        notificationService.notifyAllStaff(
                "Yêu cầu báo giá mới",
                "KH " + customer.getFullName() + " yêu cầu báo giá: " + vehicleInfo,
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

    private Quotation findById(Long id) {
        return quotationRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu báo giá"));
    }
}
