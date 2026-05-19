package com.quyenauto.lead.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.lead.dto.LeadRequest;
import com.quyenauto.lead.dto.LeadResponse;
import com.quyenauto.lead.service.LeadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/leads")
@RequiredArgsConstructor
public class LeadController {

    private final LeadService leadService;

    // Public — guest submits contact info
    @PostMapping
    public ResponseEntity<ApiResponse<Void>> create(@RequestBody LeadRequest request) {
        leadService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(null));
    }

    // Staff only — view all leads
    @GetMapping
    @PreAuthorize("hasAnyRole('STAFF','MANAGER','ADMIN')")
    public ResponseEntity<ApiResponse<List<LeadResponse>>> listAll(
            @RequestParam(defaultValue = "false") boolean pendingOnly) {
        List<LeadResponse> list = pendingOnly
                ? leadService.listPending()
                : leadService.listAll();
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    // Staff only — mark as contacted
    @PutMapping("/{id}/contacted")
    @PreAuthorize("hasAnyRole('STAFF','MANAGER','ADMIN')")
    public ResponseEntity<ApiResponse<Void>> markContacted(@PathVariable Long id) {
        leadService.markContacted(id);
        return ResponseEntity.ok(ApiResponse.noContent());
    }
}
