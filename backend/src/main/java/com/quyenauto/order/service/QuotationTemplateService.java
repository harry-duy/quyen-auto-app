package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.order.dto.QuotationTemplateRequest;
import com.quyenauto.order.dto.QuotationTemplateResponse;
import com.quyenauto.order.entity.QuotationTemplate;
import com.quyenauto.order.repository.QuotationTemplateRepository;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.entity.ProductCategory;
import com.quyenauto.product.repository.ProductCategoryRepository;
import com.quyenauto.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuotationTemplateService {

    private final QuotationTemplateRepository templateRepository;
    private final ProductCategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    public Page<QuotationTemplateResponse> getTemplates(
            Long categoryId, Long productId, Boolean activeOnly, Pageable pageable) {
        Page<QuotationTemplate> page;
        boolean onlyActive = activeOnly == null || activeOnly;

        if (productId != null && onlyActive) {
            page = templateRepository.findByProductIdAndIsActiveTrue(productId, pageable);
        } else if (categoryId != null && onlyActive) {
            page = templateRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable);
        } else if (onlyActive) {
            page = templateRepository.findByIsActiveTrue(pageable);
        } else {
            page = templateRepository.findAll(pageable);
        }

        return page.map(QuotationTemplateResponse::from);
    }

    public QuotationTemplateResponse getTemplate(Long id) {
        return QuotationTemplateResponse.from(findById(id));
    }

    @Transactional
    public QuotationTemplateResponse create(QuotationTemplateRequest request) {
        QuotationTemplate template = QuotationTemplate.builder().build();
        apply(template, request);
        return QuotationTemplateResponse.from(templateRepository.save(template));
    }

    @Transactional
    public QuotationTemplateResponse update(Long id, QuotationTemplateRequest request) {
        QuotationTemplate template = findById(id);
        apply(template, request);
        return QuotationTemplateResponse.from(templateRepository.save(template));
    }

    @Transactional
    public QuotationTemplateResponse toggleActive(Long id) {
        QuotationTemplate template = findById(id);
        template.setIsActive(!Boolean.TRUE.equals(template.getIsActive()));
        return QuotationTemplateResponse.from(templateRepository.save(template));
    }

    private QuotationTemplate findById(Long id) {
        return templateRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy mẫu báo giá"));
    }

    private void apply(QuotationTemplate template, QuotationTemplateRequest request) {
        ProductCategory category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy danh mục"));
        }

        Product product = null;
        if (request.getProductId() != null) {
            product = productRepository.findById(request.getProductId())
                    .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy sản phẩm"));
            if (category == null) {
                category = product.getCategory();
            }
        }

        template.setCategory(category);
        template.setProduct(product);
        template.setName(request.getName().trim());
        template.setDescription(blankToNull(request.getDescription()));
        template.setVehicleModel(blankToNull(request.getVehicleModel()));
        template.setChassisWidth(request.getChassisWidth());
        template.setBoxType(blankToNull(request.getBoxType()));
        template.setAcType(blankToNull(request.getAcType()));
        template.setAcModel(blankToNull(request.getAcModel()));
        template.setSpecifications(blankToNull(request.getSpecifications()));
        template.setBasePrice(request.getBasePrice() != null
                ? request.getBasePrice()
                : java.math.BigDecimal.ZERO);
        template.setOptionPrices(blankToNull(request.getOptionPrices()));
        template.setManagerNote(blankToNull(request.getManagerNote()));
        template.setIsActive(request.getIsActive() == null || request.getIsActive());
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
