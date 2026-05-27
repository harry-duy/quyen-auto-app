# Ghi chú họp — Quyen Auto App

---

## Họp 25/05/2026

### Thay đổi luồng chính

#### Phía Khách Hàng (Customer App)
- KH **chỉ xem trạng thái** các đơn hàng đã đặt — không tạo báo giá trực tiếp nữa.

#### Phía Nhân Viên (Staff App) — Luồng tạo Báo Giá

```
NV nhận KH (chọn từ DS hoặc tạo mới)
  → NV tạo BG:
      - Chọn loại xe → thông tin SP tự điền từ data (giá, kỹ thuật thùng, quy cách)
      - Hoặc chọn "Sản phẩm mới" → điền 1 ô thông tin dự án → gửi y/c Manager tạo giá
  → NV gửi BG chờ Manager xác nhận  (status: PENDING_APPROVAL)
  → Manager duyệt BG đúng/sai       (status: APPROVED / REJECTED)
  → NV gửi BG cho KH (App / Zalo / Email)  (status: SENT)
  → KH xác nhận
  → Xuất Hợp Đồng
```

#### Phía Manager
| Hành động | Thời điểm |
|-----------|-----------|
| Tạo danh sách sản phẩm, giá, quy cách | Chuẩn bị data |
| Tạo danh sách khách hàng mẫu | Chuẩn bị data |
| Xử lý yêu cầu "Sản phẩm mới" từ NV | Khi NV gửi request |
| **Xác nhận Báo Giá** trước khi NV gửi cho KH | Bắt buộc — mỗi BG |

---

### Các điểm cụ thể

1. **KH chỉ xem trạng thái đơn** đã đặt hàng — không tạo báo giá.
2. **NV là người tạo báo giá** — không phải KH.
3. **Thông tin SP tự điền** từ loại xe trong data (kích thước, giá cơ bản, quy cách).
4. **Sản phẩm mới:** Thêm option "Sản phẩm mới" trong form → chỉ cần 1 ô điền thông tin dự án → Manager sẽ tạo giá.
5. **Anh Tuấn** tạo DS sản phẩm, giá, quy cách sẵn + DS khách hàng mẫu.
6. Sau khi NV điền xong thông tin SP → tạo BG → điền thêm thông tin KH → gửi chờ **Manager xác nhận**.
7. Sửa lỗi & điều chỉnh → họp lại **29/05**.

---

### Trạng thái Báo Giá (mới)

| Status | Ý nghĩa |
|--------|---------|
| `DRAFT` | NV đang soạn (chưa gửi) |
| `PENDING_APPROVAL` | NV đã gửi — chờ Manager duyệt |
| `APPROVED` | Manager đã duyệt — NV chưa gửi cho KH |
| `SENT` | NV đã gửi cho KH |
| `ACCEPTED` | KH xác nhận → tạo Đơn Hàng |
| `REJECTED` | Manager từ chối hoặc KH từ chối |
| `EXPIRED` | Hết hạn |

> Các status cũ (`PENDING`, `QUOTED`) giữ lại để tương thích với dữ liệu hiện có.

---

## TODO — Sprint hiện tại

### Backend
- [x] Thêm trạng thái: `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `SENT`
- [x] Thêm fields: `approvedBy`, `approvedAt`, `sentAt`, `isStaffCreated`, `isNewProductRequest`, `newProductDescription`
- [x] Endpoint: `POST /staff/quotations/create` — NV tạo BG cho KH
- [x] Endpoint: `PATCH /staff/quotations/{id}/submit-approval` — NV gửi chờ duyệt
- [x] Endpoint: `PATCH /manager/quotations/{id}/approve` — Manager duyệt
- [x] Endpoint: `PATCH /manager/quotations/{id}/reject` — Manager từ chối
- [x] Endpoint: `PATCH /staff/quotations/{id}/send` — NV gửi cho KH
- [x] Endpoint: `GET /manager/quotations/pending-approval` — DS chờ duyệt
- [x] Migration V14

### Flutter — Staff App
- [x] Màn hình tạo BG mới (staff-only, có chọn KH + form SP)
- [x] Option "Sản phẩm mới" trong form
- [x] Tab Manager duyệt BG (PENDING_APPROVAL list)
- [x] Nút "Gửi cho KH" trên BG đã APPROVED
- [x] Cập nhật filter chips với status mới

### Flutter — Customer App
- [ ] Ẩn nút tạo báo giá trực tiếp (giữ lại để backward compat với lead flow)
