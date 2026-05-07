package com.quyenauto.user.repository;

import com.quyenauto.user.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DepartmentRepository extends JpaRepository<Department, Long> {

    List<Department> findByIsActiveTrueOrderByNameAsc();

    boolean existsByName(String name);
}
