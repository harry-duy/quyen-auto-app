package com.quyenauto.warranty.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.warranty.dto.*;

import java.util.List;
import com.quyenauto.warranty.entity.Vehicle;
import com.quyenauto.warranty.entity.WarrantyLog;
import com.quyenauto.warranty.entity.WarrantyRequest;
import com.quyenauto.warranty.repository.VehicleRepository;
import com.quyenauto.warranty.repository.WarrantyRequestRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class WarrantyService {

    private final WarrantyRequestRepository warrantyRepository;
    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<VehicleDetailResponse> getMyVehicles(Long customerId) {
        return vehicleRepository.findByOwnerId(customerId)
                .stream()
                .map(VehicleDetailResponse::from)
                .collect(java.util.stream.Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<WarrantyResponse> getByCustomer(Long customerId, Pageable pageable) {
        return warrantyRepository.findByCustomerId(customerId, pageable).map(WarrantyResponse::from);
    }

    @Transactional(readOnly = true)
    public Page<WarrantyResponse> getAll(String status, Pageable pageable) {
        if (status != null) {
            WarrantyRequest.WarrantyStatus ws = WarrantyRequest.WarrantyStatus.valueOf(status.toUpperCase());
            return warrantyRepository.findByStatus(ws, pageable).map(WarrantyResponse::from);
        }
        return warrantyRepository.findAll(pageable).map(WarrantyResponse::from);
    }

    @Transactional(readOnly = true)
    public WarrantyResponse getById(Long id) {
        return WarrantyResponse.from(findById(id));
    }

    @Transactional
    public WarrantyResponse create(Long customerId, CreateWarrantyRequest request) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        Vehicle vehicle = vehicleRepository.findById(request.getVehicleId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy xe"));

        if (!vehicle.getOwner().getId().equals(customerId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Xe không thuộc quyền sở hữu của bạn");
        }

        WarrantyRequest warranty = WarrantyRequest.builder()
                .vehicle(vehicle)
                .customer(customer)
                .issueDescription(request.getIssueDescription())
                .status(WarrantyRequest.WarrantyStatus.PENDING)
                .build();

        return WarrantyResponse.from(warrantyRepository.save(warranty));
    }

    @Transactional
    public WarrantyResponse assignTechnician(Long id, Long staffId, AssignTechnicianRequest request) {
        WarrantyRequest warranty = findById(id);

        User technician = userRepository.findById(request.getTechnicianId())
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy kỹ thuật viên"));

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        warranty.setTechnician(technician);
        warranty.setTechnicianName(technician.getFullName());
        warranty.setScheduledDate(request.getScheduledDate());
        warranty.setStatus(WarrantyRequest.WarrantyStatus.IN_PROGRESS);

        WarrantyLog log = WarrantyLog.builder()
                .warrantyRequest(warranty)
                .action("ASSIGN_TECHNICIAN")
                .note("Phân công kỹ thuật viên: " + technician.getFullName())
                .performedBy(staff)
                .build();
        warranty.getLogs().add(log);

        return WarrantyResponse.from(warrantyRepository.save(warranty));
    }

    @Transactional
    public WarrantyResponse updateResult(Long id, Long staffId, UpdateWarrantyResultRequest request) {
        WarrantyRequest warranty = findById(id);

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        WarrantyRequest.WarrantyStatus newStatus = WarrantyRequest.WarrantyStatus.valueOf(request.getStatus().toUpperCase());
        warranty.setStatus(newStatus);
        warranty.setResult(request.getResult());

        WarrantyLog log = WarrantyLog.builder()
                .warrantyRequest(warranty)
                .action("UPDATE_RESULT")
                .note(request.getNote())
                .performedBy(staff)
                .build();
        warranty.getLogs().add(log);

        return WarrantyResponse.from(warrantyRepository.save(warranty));
    }

    private WarrantyRequest findById(Long id) {
        return warrantyRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu bảo hành"));
    }
}
