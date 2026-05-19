package com.quyenauto.lead.repository;

import com.quyenauto.lead.entity.Lead;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LeadRepository extends JpaRepository<Lead, Long> {
    List<Lead> findAllByOrderByCreatedAtDesc();
    List<Lead> findByContactedFalseOrderByCreatedAtDesc();
}
