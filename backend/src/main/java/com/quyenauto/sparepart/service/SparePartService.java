package com.quyenauto.sparepart.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.common.service.CloudinaryService;
import com.quyenauto.sparepart.dto.CreateSparePartRequest;
import com.quyenauto.sparepart.dto.SparePartResponse;
import com.quyenauto.sparepart.dto.UpdateSparePartRequest;
import com.quyenauto.sparepart.entity.SparePart;
import com.quyenauto.sparepart.repository.SparePartRepository;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SparePartService {

    private static final Logger log = LoggerFactory.getLogger(SparePartService.class);

    private final SparePartRepository sparePartRepository;
    private final CloudinaryService cloudinaryService;
    private final SparePartAuditService auditService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** Đường dẫn file Excel cố định trên server, tự cập nhật mỗi khi dữ liệu thay đổi. */
    @Value("${app.spare-parts.excel-file-path:./data/spare-parts.xlsx}")
    private String excelFilePath;

    /** Khoá ghi file để tránh hỏng file khi nhiều thao tác cùng lúc. */
    private final Object excelFileLock = new Object();

    // ── Create ──────────────────────────────────────────────────────────────

    @Transactional
    public SparePartResponse create(CreateSparePartRequest request, MultipartFile image) {
        if (image == null || image.isEmpty()) {
            throw new BusinessException("Hình ảnh sản phẩm là bắt buộc");
        }
        validateImage(image);
        // Kiểm tra trùng mã phụ tùng TRƯỚC khi upload ảnh (tránh tạo ảnh thừa trên Cloudinary)
        sparePartRepository.findByPartNumber(request.getPartNumber()).ifPresent(existing -> {
            throw new BusinessException("Mã phụ tùng '" + request.getPartNumber() + "' đã tồn tại");
        });
        // Upload product image (kèm nén/tối ưu tự động khi phân phối)
        String imageUrl = optimizeImageUrl(cloudinaryService.upload(image, "spare-parts"));

        // Build entity (no QR yet — need ID first)
        SparePart part = SparePart.builder()
                .name(request.getName())
                .partNumber(request.getPartNumber())
                .category(request.getCategory())
                .brand(request.getBrand())
                .description(request.getDescription())
                .unit(request.getUnit())
                .quantityInStock(request.getQuantityInStock())
                .price(request.getPrice())
                .imageUrl(imageUrl)
                .build();

        SparePart saved = sparePartRepository.save(part);

        // Generate QR and update
        String qrUrl = generateAndUploadQr(saved);
        saved.setQrCodeUrl(qrUrl);
        saved = sparePartRepository.save(saved);

        // Ghi nhật ký thao tác
        auditService.record(saved.getId(), saved.getPartNumber(), "CREATE", "Thêm mới phụ tùng");

        // Tự ghi file Excel cố định trên server
        syncExcelToDisk();

        return toResponse(saved);
    }

    // ── Update ──────────────────────────────────────────────────────────────

    @Transactional
    public SparePartResponse update(Long id, UpdateSparePartRequest request, MultipartFile image) {
        SparePart part = sparePartRepository.findById(id)
                .filter(SparePart::getIsActive)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phụ tùng với id: " + id));

        boolean qrNeedsRefresh = false;
        if (request.getName() != null) { part.setName(request.getName()); qrNeedsRefresh = true; }
        if (request.getPartNumber() != null && !request.getPartNumber().equals(part.getPartNumber())) {
            // Đổi mã phụ tùng — kiểm tra mã mới chưa bị phụ tùng khác chiếm
            sparePartRepository.findByPartNumber(request.getPartNumber()).ifPresent(other -> {
                if (!other.getId().equals(part.getId())) {
                    throw new BusinessException("Mã phụ tùng '" + request.getPartNumber() + "' đã tồn tại");
                }
            });
            part.setPartNumber(request.getPartNumber());
            qrNeedsRefresh = true;
        }
        if (request.getCategory() != null) part.setCategory(request.getCategory());
        if (request.getBrand() != null) part.setBrand(request.getBrand());
        if (request.getDescription() != null) part.setDescription(request.getDescription());
        if (request.getUnit() != null) part.setUnit(request.getUnit());
        if (request.getQuantityInStock() != null) part.setQuantityInStock(request.getQuantityInStock());
        if (request.getPrice() != null) part.setPrice(request.getPrice());

        if (image != null && !image.isEmpty()) {
            validateImage(image);
            String imageUrl = optimizeImageUrl(cloudinaryService.upload(image, "spare-parts"));
            part.setImageUrl(imageUrl);
            qrNeedsRefresh = true;
        }

        if (qrNeedsRefresh) {
            part.setQrCodeUrl(generateAndUploadQr(part));
        }

        SparePart saved = sparePartRepository.save(part);

        // Ghi nhật ký thao tác
        auditService.record(saved.getId(), saved.getPartNumber(), "UPDATE", "Cập nhật thông tin phụ tùng");

        // Tự ghi file Excel cố định trên server
        syncExcelToDisk();

        return toResponse(saved);
    }

    // ── Queries ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public PageResponse<SparePartResponse> getAll(String keyword, String category, Pageable pageable) {
        Page<SparePart> page;
        boolean hasFilter = (keyword != null && !keyword.isBlank()) || (category != null && !category.isBlank());
        if (hasFilter) {
            page = sparePartRepository.search(
                    (keyword == null || keyword.isBlank()) ? null : keyword,
                    (category == null || category.isBlank()) ? null : category,
                    pageable);
        } else {
            page = sparePartRepository.findAllByIsActiveTrue(pageable);
        }
        return PageResponse.of(page.map(this::toResponse));
    }

    @Transactional(readOnly = true)
    public SparePartResponse getById(Long id) {
        return sparePartRepository.findById(id)
                .filter(SparePart::getIsActive)
                .map(this::toResponse)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phụ tùng với id: " + id));
    }

    // ── Soft Delete ──────────────────────────────────────────────────────────

    public void delete(Long id) {
        SparePart part = sparePartRepository.findById(id)
                .filter(SparePart::getIsActive)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy phụ tùng với id: " + id));
        part.setIsActive(false);
        sparePartRepository.save(part);

        // Ghi nhật ký thao tác
        auditService.record(part.getId(), part.getPartNumber(), "DELETE", "Xoá phụ tùng");

        // Tự ghi file Excel cố định trên server
        syncExcelToDisk();
    }

    // ── Excel Export ──────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public byte[] exportToExcel() {
        return buildExcelBytes();
    }

    /** Ghi (đè) toàn bộ phụ tùng đang hoạt động ra file Excel cố định trên server.
     *  Best-effort: lỗi ghi file chỉ ghi log, không làm hỏng thao tác thêm/sửa/xoá. */
    public void syncExcelToDisk() {
        try {
            byte[] bytes = buildExcelBytes();
            synchronized (excelFileLock) {
                Path path = Paths.get(excelFilePath);
                if (path.getParent() != null) {
                    Files.createDirectories(path.getParent());
                }
                Files.write(path, bytes);
            }
            log.info("Đã cập nhật file Excel phụ tùng: {}", excelFilePath);
        } catch (Exception e) {
            log.warn("Không thể ghi file Excel phụ tùng ({}): {}", excelFilePath, e.getMessage());
        }
    }

    private byte[] buildExcelBytes() {
        List<SparePart> parts = sparePartRepository.findAllActiveOrderByName();
        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Spare Parts");

            // Header style
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // Header row
            String[] headers = {"ID", "Part Number", "Name", "Category", "Brand", "Unit",
                                 "Qty in Stock", "Price", "Image URL", "QR URL", "Created At"};
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            int rowIdx = 1;
            for (SparePart p : parts) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(p.getId());
                row.createCell(1).setCellValue(p.getPartNumber() != null ? p.getPartNumber() : "");
                row.createCell(2).setCellValue(p.getName() != null ? p.getName() : "");
                row.createCell(3).setCellValue(p.getCategory() != null ? p.getCategory() : "");
                row.createCell(4).setCellValue(p.getBrand() != null ? p.getBrand() : "");
                row.createCell(5).setCellValue(p.getUnit() != null ? p.getUnit() : "");
                row.createCell(6).setCellValue(p.getQuantityInStock() != null ? p.getQuantityInStock() : 0);
                row.createCell(7).setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0.0);
                row.createCell(8).setCellValue(p.getImageUrl() != null ? p.getImageUrl() : "");
                row.createCell(9).setCellValue(p.getQrCodeUrl() != null ? p.getQrCodeUrl() : "");
                row.createCell(10).setCellValue(p.getCreatedAt() != null ? p.getCreatedAt().format(fmt) : "");
            }

            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            workbook.write(out);
            return out.toByteArray();
        } catch (IOException e) {
            throw new BusinessException("Xuất Excel thất bại: " + e.getMessage());
        }
    }

    // ── Image Validation ──────────────────────────────────────────────────────

    /** Chỉ chấp nhận tệp ảnh (content-type bắt đầu bằng "image/"). */
    private void validateImage(MultipartFile image) {
        String contentType = image.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
            throw new BusinessException("Tệp tải lên phải là hình ảnh (jpg, png, ...)");
        }
    }

    /** Chèn transformation Cloudinary f_auto,q_auto để tự nén/tối ưu ảnh khi phân phối. */
    private String optimizeImageUrl(String url) {
        if (url == null) return null;
        final String marker = "/upload/";
        int i = url.indexOf(marker);
        if (i < 0) return url;
        int insertAt = i + marker.length();
        if (url.startsWith("f_auto", insertAt) || url.startsWith("q_auto", insertAt)) {
            return url; // đã có transformation, tránh chèn trùng
        }
        return url.substring(0, insertAt) + "f_auto,q_auto/" + url.substring(insertAt);
    }

    // ── QR Code Generation ────────────────────────────────────────────────────

    private String generateAndUploadQr(SparePart part) {
        try {
            java.util.Map<String, Object> payloadMap = new java.util.LinkedHashMap<>();
            payloadMap.put("id", part.getId() != null ? part.getId() : 0);
            payloadMap.put("partNumber", part.getPartNumber() != null ? part.getPartNumber() : "");
            payloadMap.put("name", part.getName() != null ? part.getName() : "");
            payloadMap.put("imageUrl", part.getImageUrl() != null ? part.getImageUrl() : "");
            String payload = objectMapper.writeValueAsString(payloadMap);

            QRCodeWriter qrWriter = new QRCodeWriter();
            BitMatrix matrix = qrWriter.encode(payload, BarcodeFormat.QR_CODE, 300, 300);

            ByteArrayOutputStream pngOut = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", pngOut);
            byte[] pngBytes = pngOut.toByteArray();

            String filename = "qr-" + (part.getPartNumber() != null ? part.getPartNumber() : part.getId()) + ".png";
            MultipartFile qrFile = new ByteArrayMultipartFile(filename, "image/png", pngBytes);

            return cloudinaryService.upload(qrFile, "qr-codes");
        } catch (WriterException | IOException e) {
            throw new BusinessException("Tạo QR thất bại: " + e.getMessage());
        }
    }

    // ── Mapper ────────────────────────────────────────────────────────────────

    private SparePartResponse toResponse(SparePart p) {
        return SparePartResponse.builder()
                .id(p.getId())
                .name(p.getName())
                .partNumber(p.getPartNumber())
                .category(p.getCategory())
                .brand(p.getBrand())
                .description(p.getDescription())
                .unit(p.getUnit())
                .quantityInStock(p.getQuantityInStock())
                .price(p.getPrice())
                .imageUrl(p.getImageUrl())
                .qrCodeUrl(p.getQrCodeUrl())
                .isActive(p.getIsActive())
                .createdAt(p.getCreatedAt())
                .updatedAt(p.getUpdatedAt())
                .build();
    }

    // ── Inner MultipartFile implementation (avoids spring-test dependency) ──

    private static class ByteArrayMultipartFile implements MultipartFile {

        private final String filename;
        private final String contentType;
        private final byte[] content;

        ByteArrayMultipartFile(String filename, String contentType, byte[] content) {
            this.filename = filename;
            this.contentType = contentType;
            this.content = content;
        }

        @Override
        public String getName() {
            return filename;
        }

        @Override
        public String getOriginalFilename() {
            return filename;
        }

        @Override
        public String getContentType() {
            return contentType;
        }

        @Override
        public boolean isEmpty() {
            return content == null || content.length == 0;
        }

        @Override
        public long getSize() {
            return content != null ? content.length : 0;
        }

        @Override
        public byte[] getBytes() throws IOException {
            return content;
        }

        @Override
        public InputStream getInputStream() throws IOException {
            return new ByteArrayInputStream(content != null ? content : new byte[0]);
        }

        @Override
        public void transferTo(java.io.File dest) throws IOException, IllegalStateException {
            throw new UnsupportedOperationException("transferTo not supported");
        }
    }
}
