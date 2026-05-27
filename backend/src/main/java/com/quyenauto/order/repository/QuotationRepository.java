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

    /** DS báo giá do NV tạo — cho Staff xem BG của mình */
    Page<Quotation> findByStaffIdAndIsStaffCreatedTrue(Long staffId, Pageable pageable);

    /** DS báo giá chờ Manager duyệt (toàn bộ) */
    Page<Quotation> findByStatusOrderByCreatedAtDesc(Quotation.QuotationStatus status, Pageable pageable);

    /** Đếm BG chờ duyệt — cho badge Manager */
    long countByStatusAndIsStaffCreatedTrue(Quotation.QuotationStatus status);

    /** Tất cả BG do NV tạo — có filter status */
    @Query("""
            select q from Quotation q
            where q.isStaffCreated = true
              and (:status is null or q.status = :status)
            order by q.createdAt desc
            """)
    Page<Quotation> findStaffCreatedByStatus(
            @org.springframework.data.repository.query.Param("status") Quotation.QuotationStatus status,
            Pageable pageable);

    /**
     * BG do NV cụ thể tạo, theo status (dùng cho staff-created flow).
     * Dùng field `staff` chứ không dùng `contactedBy` vì staff-created BG không
     * có contactedBy.
     */
    @Query("""
            select q from Quotation q
            where q.staff.id = :staffId
              and q.status = :status
            order by q.createdAt desc
            """)
    Page<Quotation> findByStaffIdAndStatus(
            @org.springframework.data.repository.query.Param("staffId") Long staffId,
            @org.springframework.data.repository.query.Param("status") Quotation.QuotationStatus status,
            Pageable pageable);
}
