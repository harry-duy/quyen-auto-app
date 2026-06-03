package com.quyenauto.order.repository;

import com.quyenauto.order.entity.QuotationOption;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuotationOptionRepository extends JpaRepository<QuotationOption, Long> {
    Page<QuotationOption> findByIsActiveTrue(Pageable pageable);

    Page<QuotationOption> findByPositionAndIsActiveTrue(String position, Pageable pageable);

    Page<QuotationOption> findByPosition(String position, Pageable pageable);
}
