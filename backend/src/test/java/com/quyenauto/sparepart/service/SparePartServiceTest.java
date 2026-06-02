package com.quyenauto.sparepart.service;

import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.common.service.CloudinaryService;
import com.quyenauto.sparepart.dto.CreateSparePartRequest;
import com.quyenauto.sparepart.dto.SparePartResponse;
import com.quyenauto.sparepart.dto.UpdateSparePartRequest;
import com.quyenauto.sparepart.entity.SparePart;
import com.quyenauto.sparepart.repository.SparePartRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SparePartServiceTest {

    @Mock
    private SparePartRepository repository;

    @Mock
    private CloudinaryService cloudinaryService;

    @Mock
    private SparePartAuditService auditService;

    private SparePartService service;

    @BeforeEach
    void setUp(@TempDir Path tempDir) {
        service = new SparePartService(repository, cloudinaryService, auditService);
        ReflectionTestUtils.setField(service, "excelFilePath",
                tempDir.resolve("spare-parts.xlsx").toString());
        // syncExcelToDisk() được gọi sau mỗi create/update/delete
        lenient().when(repository.findAllActiveOrderByName()).thenReturn(List.of());
    }

    private MultipartFile imageMock(String contentType, boolean empty) {
        MultipartFile file = mock(MultipartFile.class);
        lenient().when(file.isEmpty()).thenReturn(empty);
        lenient().when(file.getContentType()).thenReturn(contentType);
        return file;
    }

    private CreateSparePartRequest createRequest(String partNumber) {
        CreateSparePartRequest req = new CreateSparePartRequest();
        req.setName("Lọc dầu");
        req.setPartNumber(partNumber);
        req.setCategory("Engine");
        req.setBrand("Bosch");
        req.setUnit("Piece");
        req.setQuantityInStock(10);
        req.setPrice(new BigDecimal("150000"));
        return req;
    }

    // ── create() ──────────────────────────────────────────────────────────────

    @Test
    void create_throwsWhenImageMissing() {
        assertThatThrownBy(() -> service.create(createRequest("PN-1"), null))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("Hình ảnh");
        verifyNoInteractions(cloudinaryService);
    }

    @Test
    void create_throwsWhenFileNotImage() {
        MultipartFile notImage = imageMock("text/plain", false);
        assertThatThrownBy(() -> service.create(createRequest("PN-1"), notImage))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("hình ảnh");
        verifyNoInteractions(cloudinaryService);
    }

    @Test
    void create_throwsWhenPartNumberDuplicate() {
        MultipartFile image = imageMock("image/png", false);
        when(repository.findByPartNumber("PN-DUP")).thenReturn(Optional.of(new SparePart()));

        assertThatThrownBy(() -> service.create(createRequest("PN-DUP"), image))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("đã tồn tại");

        // Trùng mã phải bị chặn TRƯỚC khi upload ảnh
        verifyNoInteractions(cloudinaryService);
    }

    @Test
    void create_success_uploadsImageAndQr() {
        MultipartFile image = imageMock("image/png", false);
        when(repository.findByPartNumber("PN-NEW")).thenReturn(Optional.empty());
        when(cloudinaryService.upload(any(), eq("spare-parts"))).thenReturn("http://img");
        when(cloudinaryService.upload(any(), eq("qr-codes"))).thenReturn("http://qr");
        when(repository.save(any(SparePart.class))).thenAnswer(inv -> {
            SparePart s = inv.getArgument(0);
            if (s.getId() == null) s.setId(1L);
            return s;
        });

        SparePartResponse res = service.create(createRequest("PN-NEW"), image);

        assertThat(res.getId()).isEqualTo(1L);
        assertThat(res.getPartNumber()).isEqualTo("PN-NEW");
        assertThat(res.getImageUrl()).isEqualTo("http://img");
        assertThat(res.getQrCodeUrl()).isEqualTo("http://qr");
        verify(cloudinaryService).upload(any(), eq("spare-parts"));
        verify(cloudinaryService).upload(any(), eq("qr-codes"));
        verify(repository, times(2)).save(any(SparePart.class)); // lần 1 lấy id, lần 2 lưu QR
        verify(auditService).record(eq(1L), eq("PN-NEW"), eq("CREATE"), any());
    }

    // ── update() ──────────────────────────────────────────────────────────────

    @Test
    void update_throwsNotFoundWhenMissing() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.update(99L, new UpdateSparePartRequest(), null))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getStatus()).isEqualTo(HttpStatus.NOT_FOUND));
    }

    @Test
    void update_throwsWhenNewPartNumberTakenByAnother() {
        SparePart existing = SparePart.builder().partNumber("PN-A").isActive(true).build();
        existing.setId(1L);
        SparePart other = SparePart.builder().partNumber("PN-B").isActive(true).build();
        other.setId(2L);
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.findByPartNumber("PN-B")).thenReturn(Optional.of(other));

        UpdateSparePartRequest req = new UpdateSparePartRequest();
        req.setPartNumber("PN-B");

        assertThatThrownBy(() -> service.update(1L, req, null))
                .isInstanceOf(BusinessException.class)
                .hasMessageContaining("đã tồn tại");
    }

    @Test
    void update_success_changesQuantityWithoutRegeneratingQr() {
        SparePart existing = SparePart.builder()
                .partNumber("PN-A").name("Lọc dầu").isActive(true).quantityInStock(10).build();
        existing.setId(1L);
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(SparePart.class))).thenAnswer(inv -> inv.getArgument(0));

        UpdateSparePartRequest req = new UpdateSparePartRequest();
        req.setQuantityInStock(25);

        SparePartResponse res = service.update(1L, req, null);

        assertThat(res.getQuantityInStock()).isEqualTo(25);
        // Chỉ đổi số lượng → KHÔNG sinh lại QR (không upload Cloudinary)
        verifyNoInteractions(cloudinaryService);
    }

    // ── getById() ─────────────────────────────────────────────────────────────

    @Test
    void getById_throwsNotFoundWhenInactive() {
        SparePart inactive = SparePart.builder().isActive(false).build();
        inactive.setId(5L);
        when(repository.findById(5L)).thenReturn(Optional.of(inactive));

        assertThatThrownBy(() -> service.getById(5L))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getStatus()).isEqualTo(HttpStatus.NOT_FOUND));
    }

    @Test
    void getById_success() {
        SparePart part = SparePart.builder().partNumber("PN-A").name("Lọc dầu").isActive(true).build();
        part.setId(7L);
        when(repository.findById(7L)).thenReturn(Optional.of(part));

        SparePartResponse res = service.getById(7L);

        assertThat(res.getId()).isEqualTo(7L);
        assertThat(res.getPartNumber()).isEqualTo("PN-A");
    }

    // ── delete() ──────────────────────────────────────────────────────────────

    @Test
    void delete_softDeletesByClearingActiveFlag() {
        SparePart part = SparePart.builder().isActive(true).build();
        part.setId(3L);
        when(repository.findById(3L)).thenReturn(Optional.of(part));
        when(repository.save(any(SparePart.class))).thenAnswer(inv -> inv.getArgument(0));

        service.delete(3L);

        assertThat(part.getIsActive()).isFalse();
        verify(repository).save(part);
        verify(auditService).record(any(), any(), eq("DELETE"), any());
    }

    @Test
    void delete_throwsNotFoundWhenMissing() {
        when(repository.findById(404L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.delete(404L))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getStatus()).isEqualTo(HttpStatus.NOT_FOUND));
    }

    // ── getAll() ──────────────────────────────────────────────────────────────

    @Test
    void getAll_usesSearchWhenKeywordPresent() {
        SparePart part = SparePart.builder().partNumber("PN-A").name("Lọc dầu").isActive(true).build();
        part.setId(1L);
        Page<SparePart> page = new PageImpl<>(List.of(part));
        when(repository.search(eq("lọc"), ArgumentMatchers.isNull(), any())).thenReturn(page);

        PageResponse<SparePartResponse> res = service.getAll("lọc", null, PageRequest.of(0, 20));

        assertThat(res.getContent()).hasSize(1);
        verify(repository).search(eq("lọc"), ArgumentMatchers.isNull(), any());
        verify(repository, never()).findAllByIsActiveTrue(any());
    }

    @Test
    void getAll_usesPlainListWhenNoFilter() {
        when(repository.findAllByIsActiveTrue(any())).thenReturn(new PageImpl<>(List.of()));

        service.getAll(null, null, PageRequest.of(0, 20));

        verify(repository).findAllByIsActiveTrue(any());
        verify(repository, never()).search(any(), any(), any());
    }

    // ── exportToExcel() ───────────────────────────────────────────────────────

    @Test
    void exportToExcel_returnsValidXlsxBytes() {
        SparePart part = SparePart.builder()
                .partNumber("PN-A").name("Lọc dầu").category("Engine")
                .quantityInStock(10).price(new BigDecimal("150000")).isActive(true).build();
        part.setId(1L);
        when(repository.findAllActiveOrderByName()).thenReturn(List.of(part));

        byte[] bytes = service.exportToExcel();

        assertThat(bytes).isNotEmpty();
        // Chữ ký file .xlsx (zip): 'P','K'
        assertThat(bytes[0]).isEqualTo((byte) 0x50);
        assertThat(bytes[1]).isEqualTo((byte) 0x4B);
    }
}
