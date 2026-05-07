package com.quyenauto.warranty.repository;

import com.quyenauto.warranty.entity.WarrantyRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WarrantyRequestRepository extends JpaRepository<WarrantyRequest, Long> {

    Page<WarrantyRequest> findByCustomerId(Long customerId, Pageable pageable);

    Page<WarrantyRequest> findByStatus(WarrantyRequest.WarrantyStatus status, Pageable pageable);

    Page<WarrantyRequest> findByTechnicianId(Long technicianId, Pageable pageable);

    long countByStatus(WarrantyRequest.WarrantyStatus status);
}
