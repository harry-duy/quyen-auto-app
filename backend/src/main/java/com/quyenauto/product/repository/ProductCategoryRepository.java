package com.quyenauto.product.repository;

import com.quyenauto.product.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductCategoryRepository extends JpaRepository<ProductCategory, Long> {

    List<ProductCategory> findByIsActiveTrueOrderBySortOrderAsc();

    boolean existsByName(String name);

    Optional<ProductCategory> findByName(String name);
}
