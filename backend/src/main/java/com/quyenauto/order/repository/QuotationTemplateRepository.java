package com.quyenauto.order.repository;

import com.quyenauto.order.entity.QuotationTemplate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuotationTemplateRepository extends JpaRepository<QuotationTemplate, Long> {
    Page<QuotationTemplate> findByIsActiveTrue(Pageable pageable);

    Page<QuotationTemplate> findByCategoryIdAndIsActiveTrue(Long categoryId, Pageable pageable);

    Page<QuotationTemplate> findByProductIdAndIsActiveTrue(Long productId, Pageable pageable);
}
