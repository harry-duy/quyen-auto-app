package com.quyenauto.user.repository;

import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByPhone(String phone);

    Optional<User> findByEmail(String email);

    Optional<User> findByZaloId(String zaloId);

    boolean existsByPhone(String phone);

    boolean existsByEmail(String email);

    boolean existsByEmployeeCode(String employeeCode);

    Page<User> findByRole(UserRole role, Pageable pageable);

    Page<User> findByDepartmentId(Long departmentId, Pageable pageable);

    long countByDepartmentId(Long departmentId);

    Page<User> findByRoleInAndDepartmentId(java.util.List<UserRole> roles, Long departmentId, Pageable pageable);

    Page<User> findByRoleIn(java.util.List<UserRole> roles, Pageable pageable);

    @Query("SELECT u FROM User u WHERE u.role = :role AND " +
           "(LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           " u.phone LIKE CONCAT('%', :keyword, '%') OR " +
           " LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<User> searchByRoleAndKeyword(@Param("role") UserRole role,
                                      @Param("keyword") String keyword,
                                      Pageable pageable);
}
