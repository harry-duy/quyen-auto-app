package com.quyenauto.user.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.user.dto.CreateDepartmentRequest;
import com.quyenauto.user.dto.DepartmentResponse;
import com.quyenauto.user.entity.Department;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.DepartmentRepository;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DepartmentService {

    private final DepartmentRepository departmentRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<DepartmentResponse> getAll() {
        return departmentRepository.findByIsActiveTrueOrderByNameAsc().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public DepartmentResponse getById(Long id) {
        Department dept = departmentRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phòng ban"));
        return toResponse(dept);
    }

    @Transactional
    public DepartmentResponse create(CreateDepartmentRequest request) {
        if (departmentRepository.existsByName(request.getName())) {
            throw new BusinessException("Tên phòng ban đã tồn tại");
        }

        Department dept = Department.builder()
                .name(request.getName())
                .description(request.getDescription())
                .managerId(request.getManagerId())
                .isActive(true)
                .build();

        return toResponse(departmentRepository.save(dept));
    }

    @Transactional
    public DepartmentResponse update(Long id, CreateDepartmentRequest request) {
        Department dept = departmentRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phòng ban"));

        dept.setName(request.getName());
        dept.setDescription(request.getDescription());
        if (request.getManagerId() != null) {
            dept.setManagerId(request.getManagerId());
        }

        return toResponse(departmentRepository.save(dept));
    }

    private DepartmentResponse toResponse(Department dept) {
        String managerName = null;
        if (dept.getManagerId() != null) {
            managerName = userRepository.findById(dept.getManagerId())
                    .map(User::getFullName).orElse(null);
        }
        long staffCount = userRepository.countByDepartmentId(dept.getId());
        return DepartmentResponse.from(dept, managerName, staffCount);
    }
}
