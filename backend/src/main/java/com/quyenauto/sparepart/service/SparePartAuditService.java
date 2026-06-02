package com.quyenauto.sparepart.service;

import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.sparepart.dto.SparePartAuditLogResponse;
import com.quyenauto.sparepart.entity.SparePartAuditLog;
import com.quyenauto.sparepart.repository.SparePartAuditLogRepository;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Ghi và truy vấn nhật ký thao tác (audit log) cho phụ tùng. */
@Service
@RequiredArgsConstructor
public class SparePartAuditService {

    private static final Logger log = LoggerFactory.getLogger(SparePartAuditService.class);

    private final SparePartAuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    /** Ghi một bản ghi audit. Best-effort: lỗi ghi log không làm hỏng thao tác chính. */
    public void record(Long sparePartId, String partNumber, String action, String detail) {
        try {
            String performedBy = "Hệ thống";
            Long performedById = null;

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.getName() != null && !"anonymousUser".equals(auth.getName())) {
                try {
                    performedById = Long.parseLong(auth.getName());
                    final Long uid = performedById;
                    performedBy = userRepository.findById(uid)
                            .map(u -> u.getFullName() + " (" + u.getPhone() + ")")
                            .orElse("User#" + uid);
                } catch (NumberFormatException e) {
                    performedBy = auth.getName();
                }
            }

            auditLogRepository.save(SparePartAuditLog.builder()
                    .sparePartId(sparePartId)
                    .partNumber(partNumber)
                    .action(action)
                    .performedBy(performedBy)
                    .performedById(performedById)
                    .detail(detail)
                    .build());
        } catch (Exception e) {
            log.warn("Không ghi được audit log cho phụ tùng {}: {}", partNumber, e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public PageResponse<SparePartAuditLogResponse> getAll(Pageable pageable) {
        return PageResponse.of(auditLogRepository.findAllByOrderByCreatedAtDesc(pageable).map(this::toResponse));
    }

    @Transactional(readOnly = true)
    public PageResponse<SparePartAuditLogResponse> getByPartId(Long sparePartId, Pageable pageable) {
        return PageResponse.of(
                auditLogRepository.findBySparePartIdOrderByCreatedAtDesc(sparePartId, pageable).map(this::toResponse));
    }

    private SparePartAuditLogResponse toResponse(SparePartAuditLog l) {
        return SparePartAuditLogResponse.builder()
                .id(l.getId())
                .sparePartId(l.getSparePartId())
                .partNumber(l.getPartNumber())
                .action(l.getAction())
                .performedBy(l.getPerformedBy())
                .detail(l.getDetail())
                .createdAt(l.getCreatedAt())
                .build();
    }
}
