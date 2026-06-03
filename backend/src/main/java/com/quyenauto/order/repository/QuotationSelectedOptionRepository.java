package com.quyenauto.order.repository;

import com.quyenauto.order.entity.QuotationSelectedOption;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuotationSelectedOptionRepository extends JpaRepository<QuotationSelectedOption, Long> {
    List<QuotationSelectedOption> findByQuotationIdOrderByIdAsc(Long quotationId);
}
