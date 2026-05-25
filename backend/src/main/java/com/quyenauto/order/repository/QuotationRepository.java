package com.quyenauto.order.repository;

import com.quyenauto.order.entity.Quotation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;

public interface QuotationRepository extends JpaRepository<Quotation, Long> {

    Page<Quotation> findByCustomerId(Long customerId, Pageable pageable);

    Page<Quotation> findByStatus(Quotation.QuotationStatus status, Pageable pageable);

    Page<Quotation> findByStaffId(Long staffId, Pageable pageable);

    @Query("""
            select q from Quotation q
            where q.status in :statuses
              and (q.contactedBy is null or q.contactedBy.id = :staffId)
            """)
    Page<Quotation> findVisibleActiveForStaff(Long staffId, Collection<Quotation.QuotationStatus> statuses, Pageable pageable);

    @Query("""
            select q from Quotation q
            where q.status = :status
              and (q.contactedBy is null or q.contactedBy.id = :staffId)
            """)
    Page<Quotation> findVisibleByStatusForStaff(Long staffId, Quotation.QuotationStatus status, Pageable pageable);

    long countByStatus(Quotation.QuotationStatus status);
}
