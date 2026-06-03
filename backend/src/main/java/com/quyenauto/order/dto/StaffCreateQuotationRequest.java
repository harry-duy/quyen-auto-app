package com.quyenauto.order.dto;

import jakarta.validation.constraints.Min;
import lombok.Data;

import java.util.List;

/**
 * Request DTO khi NV tạo báo giá cho khách hàng (flow mới).
 * Giống CreateQuotationRequest nhưng thêm customerId và hỗ trợ "Sản phẩm mới".
 */
@Data
public class StaffCreateQuotationRequest {

    /** ID khách hàng có sẵn trong hệ thống (null nếu là khách vãng lai) */
    private Long customerId;

    /** Mẫu báo giá nội bộ do Manager cấu hình (nếu có) */
    private Long templateId;

    /** Tên khách vãng lai — dùng khi customerId == null */
    private String guestName;

    /** SĐT khách vãng lai — dùng khi customerId == null */
    private String guestPhone;

    /**
     * ID sản phẩm có sẵn trong hệ thống.
     * Nếu null thì isNewProductRequest = true và newProductDescription bắt buộc.
     */
    private Long productId;

    /**
     * Khi NV chọn "Sản phẩm mới" (SP chưa có trong data).
     * Khi true: productId có thể null, newProductDescription bắt buộc.
     */
    private Boolean isNewProductRequest = false;

    /** Mô tả dự án / yêu cầu khi chọn Sản phẩm mới */
    private String newProductDescription;

    private String vehicleModel;

    @Min(value = 1, message = "Số lượng tối thiểu là 1")
    private Integer quantity = 1;

    private Integer chassisWidth;
    private String boxCode;
    private String boxType;
    private String acType;
    private String acModel;
    private Boolean innerWallInsulated;

    /** JSON string chứa toàn bộ thông số kỹ thuật */
    private String specifications;

    private String weightRange;
    private String cargoType;
    private String note;

    /** Option/san pham staff chon tu kho dung chung, hoac yeu cau ngoai danh muc. */
    private List<SelectedQuotationOptionRequest> selectedOptions;
}
