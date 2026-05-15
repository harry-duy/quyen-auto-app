package com.quyenauto.user.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.user.dto.*;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public Page<UserResponse> getStaffMembers(Long departmentId, Pageable pageable) {
        List<UserRole> staffRoles = List.of(UserRole.STAFF, UserRole.MANAGER, UserRole.ADMIN);
        Page<User> page;
        if (departmentId != null) {
            page = userRepository.findByRoleInAndDepartmentId(staffRoles, departmentId, pageable);
        } else {
            page = userRepository.findByRoleIn(staffRoles, pageable);
        }
        return page.map(UserResponse::from);
    }

    public UserResponse getById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse createStaff(CreateStaffRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new BusinessException("Số điện thoại đã được sử dụng");
        }
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email đã được sử dụng");
        }
        if (request.getEmployeeCode() != null && userRepository.existsByEmployeeCode(request.getEmployeeCode())) {
            throw new BusinessException("Mã nhân viên đã tồn tại");
        }

        UserRole role = UserRole.valueOf(request.getRole().toUpperCase());
        if (role == UserRole.CUSTOMER) {
            throw new BusinessException("Không thể tạo tài khoản staff với vai trò CUSTOMER");
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .email(request.getEmail())
                .role(role)
                .isActive(true)
                .departmentId(request.getDepartmentId())
                .position(request.getPosition())
                .employeeCode(request.getEmployeeCode())
                .build();

        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public UserResponse createCustomer(CreateCustomerRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new BusinessException("Số điện thoại đã được sử dụng");
        }
        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email đã được sử dụng");
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .email(request.getEmail())
                .role(UserRole.CUSTOMER)
                .isActive(true)
                .build();

        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getEmail() != null) user.setEmail(request.getEmail());
        if (request.getAvatarUrl() != null) user.setAvatarUrl(request.getAvatarUrl());
        if (request.getDepartmentId() != null) user.setDepartmentId(request.getDepartmentId());
        if (request.getPosition() != null) user.setPosition(request.getPosition());
        if (request.getRole() != null) user.setRole(UserRole.valueOf(request.getRole().toUpperCase()));

        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public void toggleActive(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));
        user.setIsActive(!user.getIsActive());
        userRepository.save(user);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BusinessException("Mật khẩu hiện tại không đúng");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Transactional
    public UserResponse updateProfile(Long userId, UpdateUserRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getEmail() != null) user.setEmail(request.getEmail());
        if (request.getAvatarUrl() != null) user.setAvatarUrl(request.getAvatarUrl());

        return UserResponse.from(userRepository.save(user));
    }
}
