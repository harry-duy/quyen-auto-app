package com.quyenauto.order.repository;

import com.quyenauto.order.entity.Quotation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuotationRepository extends JpaRepository<Quotation, Long> {

    Page<Quotation> findByCustomerId(Long customerId, Pageable pageable);

    Page<Quotation> findByStatus(Quotation.QuotationStatus status, Pageable pageable);

    Page<Quotation> findByStaffId(Long staffId, Pageable pageable);

    long countByStatus(Quotation.QuotationStatus status);
}
