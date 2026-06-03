package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.order.dto.QuotationOptionRequest;
import com.quyenauto.order.dto.QuotationOptionResponse;
import com.quyenauto.order.entity.QuotationOption;
import com.quyenauto.order.repository.QuotationOptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuotationOptionService {
    private final QuotationOptionRepository optionRepository;

    public Page<QuotationOptionResponse> getOptions(String position, Boolean activeOnly, Pageable pageable) {
        Page<QuotationOption> page;
        if (position != null && activeOnly != null && activeOnly) {
            page = optionRepository.findByPositionAndIsActiveTrue(position, pageable);
        } else if (position != null) {
            page = optionRepository.findByPosition(position, pageable);
        } else if (activeOnly != null && activeOnly) {
            page = optionRepository.findByIsActiveTrue(pageable);
        } else {
            page = optionRepository.findAll(pageable);
        }
        return page.map(QuotationOptionResponse::from);
    }

    @Transactional
    public QuotationOptionResponse create(QuotationOptionRequest request) {
        QuotationOption option = QuotationOption.builder().build();
        apply(option, request);
        return QuotationOptionResponse.from(optionRepository.save(option));
    }

    @Transactional
    public QuotationOptionResponse update(Long id, QuotationOptionRequest request) {
        QuotationOption option = findById(id);
        apply(option, request);
        return QuotationOptionResponse.from(optionRepository.save(option));
    }

    @Transactional
    public QuotationOptionResponse toggleActive(Long id) {
        QuotationOption option = findById(id);
        option.setIsActive(!Boolean.TRUE.equals(option.getIsActive()));
        return QuotationOptionResponse.from(optionRepository.save(option));
    }

    private QuotationOption findById(Long id) {
        return optionRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay option bao gia"));
    }

    private void apply(QuotationOption option, QuotationOptionRequest request) {
        option.setName(request.getName().trim());
        option.setPosition(request.getPosition().trim().toUpperCase());
        option.setUnit(blankToDefault(request.getUnit(), "cai"));
        option.setDefaultPrice(request.getDefaultPrice() != null ? request.getDefaultPrice() : BigDecimal.ZERO);
        option.setDescription(blankToNull(request.getDescription()));
        option.setInternalNote(blankToNull(request.getInternalNote()));
        option.setIsActive(request.getIsActive() == null || request.getIsActive());
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private String blankToDefault(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }
}
