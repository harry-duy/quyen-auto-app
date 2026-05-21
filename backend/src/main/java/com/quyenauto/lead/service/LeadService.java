package com.quyenauto.lead.service;

import com.quyenauto.lead.dto.LeadRequest;
import com.quyenauto.lead.dto.LeadResponse;
import com.quyenauto.lead.entity.Lead;
import com.quyenauto.lead.repository.LeadRepository;
import com.quyenauto.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LeadService {

    private final LeadRepository leadRepository;
    private final NotificationService notificationService;

    @Transactional
    public void create(LeadRequest req) {
        Lead lead = new Lead();
        lead.setPhone(req.getPhone());
        lead.setName(req.getName());
        lead.setProductId(req.getProductId());
        lead.setProductName(req.getProductName());
        lead.setNote(req.getNote());
        lead.setSpecifications(req.getSpecifications());
        Lead saved = leadRepository.save(lead);

        // Thông báo cho tất cả staff khi có khách chưa đăng nhập yêu cầu báo giá
        String displayName = (req.getName() != null && !req.getName().isBlank())
                ? req.getName() : "Khách vãng lai";
        String productInfo = (req.getProductName() != null && !req.getProductName().isBlank())
                ? req.getProductName() : "sản phẩm";
        notificationService.notifyAllStaff(
                "Lead báo giá mới",
                displayName + " (" + req.getPhone() + ") cần báo giá: " + productInfo,
                "LEAD_NEW",
                saved.getId().toString()
        );
    }

    public List<LeadResponse> listAll() {
        return leadRepository.findAllByOrderByCreatedAtDesc()
                .stream().map(this::toResponse).toList();
    }

    public List<LeadResponse> listPending() {
        return leadRepository.findByContactedFalseOrderByCreatedAtDesc()
                .stream().map(this::toResponse).toList();
    }

    public void markContacted(Long id) {
        leadRepository.findById(id).ifPresent(lead -> {
            lead.setContacted(true);
            leadRepository.save(lead);
        });
    }

    private LeadResponse toResponse(Lead l) {
        return LeadResponse.builder()
                .id(l.getId())
                .phone(l.getPhone())
                .name(l.getName())
                .productId(l.getProductId())
                .productName(l.getProductName())
                .note(l.getNote())
                .specifications(l.getSpecifications())
                .contacted(l.isContacted())
                .createdAt(l.getCreatedAt())
                .build();
    }
}
