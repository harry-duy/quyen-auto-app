package com.quyenauto.common.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.service.CloudinaryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/upload")
@RequiredArgsConstructor
@Tag(name = "Upload", description = "Upload ảnh lên Cloudinary")
public class UploadController {

    private final CloudinaryService cloudinaryService;

    @PostMapping
    @Operation(summary = "Upload ảnh")
    public ResponseEntity<ApiResponse<String>> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(defaultValue = "general") String folder) {
        String url = cloudinaryService.upload(file, folder);
        return ResponseEntity.ok(ApiResponse.ok(url));
    }
}
