package com.quyenauto.lead.service;

import com.quyenauto.lead.dto.LeadRequest;
import com.quyenauto.lead.dto.LeadResponse;
import com.quyenauto.lead.entity.Lead;
import com.quyenauto.lead.repository.LeadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LeadService {

    private final LeadRepository leadRepository;

    public void create(LeadRequest req) {
        Lead lead = new Lead();
        lead.setPhone(req.getPhone());
        lead.setName(req.getName());
        lead.setProductId(req.getProductId());
        lead.setProductName(req.getProductName());
        lead.setNote(req.getNote());
        leadRepository.save(lead);
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
                .contacted(l.isContacted())
                .createdAt(l.getCreatedAt())
                .build();
    }
}
