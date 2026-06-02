package com.quyenauto.sparepart.repository;

import com.quyenauto.sparepart.entity.SparePart;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SparePartRepository extends JpaRepository<SparePart, Long> {

    Optional<SparePart> findByPartNumber(String partNumber);

    Page<SparePart> findAllByIsActiveTrue(Pageable pageable);

    @Query("SELECT s FROM SparePart s WHERE s.isActive = true " +
           "AND (:category IS NULL OR s.category = :category) " +
           "AND (:keyword IS NULL OR :keyword = '' OR " +
           "LOWER(s.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(s.partNumber) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(s.brand) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<SparePart> search(@Param("keyword") String keyword,
                           @Param("category") String category,
                           Pageable pageable);

    @Query("SELECT s FROM SparePart s WHERE s.isActive = true ORDER BY s.name ASC")
    List<SparePart> findAllActiveOrderByName();
}
