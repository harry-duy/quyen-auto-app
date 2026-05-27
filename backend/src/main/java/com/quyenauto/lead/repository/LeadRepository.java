package com.quyenauto.lead.repository;

import com.quyenauto.lead.entity.Lead;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LeadRepository extends JpaRepository<Lead, Long> {
    Page<Lead> findAllByOrderByCreatedAtDesc(Pageable pageable);
    Page<Lead> findByContactedFalseOrderByCreatedAtDesc(Pageable pageable);
}
