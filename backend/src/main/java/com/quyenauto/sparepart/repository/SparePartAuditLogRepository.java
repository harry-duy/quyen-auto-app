package com.quyenauto.sparepart.repository;

import com.quyenauto.sparepart.entity.SparePartAuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SparePartAuditLogRepository extends JpaRepository<SparePartAuditLog, Long> {

    Page<SparePartAuditLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<SparePartAuditLog> findBySparePartIdOrderByCreatedAtDesc(Long sparePartId, Pageable pageable);
}
