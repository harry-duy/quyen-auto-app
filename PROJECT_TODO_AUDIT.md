# Quyen Auto App - Trang thai du an (cap nhat 2026-05-11)

> File nay ghi lai trang thai implement cua tung tinh nang. Cap nhat sau moi session.
> **Cap nhat lan cuoi: 2026-05-11 (Session 7 — Production Hardening, Bước 4 OTP + Bước 5 FCM xong)**

---

## Trang thai tong the

**Tat ca chuc nang chinh da XONG.** Chi con Zalo OAuth la chua implement (can SDK ben thu 3).

**Session 7 — Production Hardening (2026-05-11):**
- ✅ Bươc 1: Tach secrets ra .env (xoa hardcoded DB_PASSWORD, JWT_SECRET)
- ✅ Bươc 2: Rate limiting POST /auth/login (Bucket4j, 5/IP/15min, 429)
- ✅ Bươc 3: Fix ChatController — kiem tra quyen vao phong chat
- ✅ Bươc 7: WebSocket auto-reconnect voi exponential backoff + re-subscribe
- ✅ Bươc 8: Fix race condition ma don hang (UUID thay vi count+1)
- ✅ Bươc 9: Workflow phe duyet huy don (CANCEL_REQUESTED + staff approve/reject)
- ✅ Bươc 6: Cloudinary upload anh dai dien (avatar) — Flutter + backend da day du
- ✅ Bươc 5: FCM Push Notification — FcmConfig + FcmPushService + NotificationService wired + Flutter register token
- ✅ Bươc 4: OTP xac minh email — V4 migration, OtpService, EmailService, OtpVerificationScreen Flutter

---

## Chi tiet tung tinh nang

### Customer App

| Tinh nang | Trang thai | Ghi chu |
|-----------|-----------|---------|
| Dang nhap / Dang ky | ✅ Done | |
| Quen mat khau | ✅ Done | Hien dialog goi hotline |
| Dang nhap Zalo | ⏸ Giu lai | Can Zalo SDK, SnackBar "Coming Soon" |
| Xem danh sach san pham | ✅ Done | |
| Chi tiet san pham + thong so | ✅ Done | |
| Yeu cau bao gia | ✅ Done | |
| Danh sach don hang (2 tab) | ✅ Done | |
| Chi tiet don hang + timeline | ✅ Done | |
| **Huy don hang** | ✅ Done | Goi `PATCH /orders/{id}/cancel` |
| Thong bao (list + danh dau doc) | ✅ Done | |
| Tab Bao hanh: xem xe | ✅ Done | |
| Tab Bao hanh: tao yeu cau | ✅ Done | |
| Them xe (AddVehicleScreen) | ✅ Done | Giai thich lien he — backend khong co POST /warranty/vehicles |
| Danh sach xe (VehicleListScreen) | ✅ Done | |
| Chat voi support | ✅ Done | REST history + WebSocket realtime |
| **Cap nhat thong tin ca nhan** | ✅ Done | Goi `PUT /auth/me` |
| **Doi mat khau** | ✅ Done | Goi `POST /auth/change-password` |

### Staff App

| Tinh nang | Trang thai | Ghi chu |
|-----------|-----------|---------|
| Dashboard tong quan | ✅ Done | |
| Quan ly don hang (filter, cap nhat trang thai) | ✅ Done | |
| Duyet bao gia | ✅ Done | |
| Quan ly bao hanh (phan cong, ket qua) | ✅ Done | |
| Chat voi khach hang | ✅ Done | |
| Ban do dai ly (Google Maps) | ✅ Done | |
| **Tim dai ly gan nhat** | ✅ Done | `GET /dealers/nearest` backend vua them |
| Quan ly phong ban | ✅ Done | MANAGER/ADMIN only |
| Quan ly nhan vien | ✅ Done | MANAGER/ADMIN only |
| Thong bao staff | ✅ Done | `GET /staff/notifications` |
| **Cap nhat thong tin ca nhan** | ✅ Done | |
| **Doi mat khau (co show/hide)** | ✅ Done | Da them toggle hien/an |
| Tro giup | ✅ Done | Bottom sheet hotline + email |

---

## Backend Endpoints — Trang thai

### Auth
| Endpoint | Trang thai |
|----------|-----------|
| `POST /auth/login` | ✅ |
| `POST /auth/register` | ✅ |
| `POST /auth/refresh` | ✅ |
| `POST /auth/logout` | ✅ |
| `GET /auth/me` | ✅ |
| `PUT /auth/me` | ✅ Vua them |
| `POST /auth/change-password` | ✅ Vua them |
| `POST /auth/zalo` | ⏸ Chua co (chi co DTO + security rule) |

### Orders
| Endpoint | Trang thai |
|----------|-----------|
| `GET /orders` | ✅ |
| `GET /orders/{id}` | ✅ |
| `GET /orders/code/{code}` | ✅ |
| `PATCH /orders/{id}/cancel` | ✅ Vua them |
| `GET /staff/orders` | ✅ |
| `PATCH /staff/orders/{id}/status` | ✅ |

### Notifications
| Endpoint | Trang thai |
|----------|-----------|
| `GET /notifications` | ✅ |
| `GET /notifications/unread-count` | ✅ |
| `POST /notifications/mark-read` | ✅ |
| `POST /notifications/{id}/read` | ✅ Vua them |
| `POST /notifications/fcm-token` | ✅ |
| `DELETE /notifications/fcm-token/{token}` | ✅ |

### Dealers
| Endpoint | Trang thai |
|----------|-----------|
| `GET /dealers` | ✅ |
| `GET /dealers/{id}` | ✅ |
| `GET /dealers/nearest` | ✅ Vua them |
| `POST /admin/dealers` | ✅ |
| `PUT /admin/dealers/{id}` | ✅ |

### Chat, Warranty, Products, Quotations, Reports
> Tat ca da co day du tu truoc. Xem `FIX_NOTES.md` de biet chi tiet.

---

## Van de ky thuat biet truoc (khong urgent)

| Van de | File | Muc do |
|--------|------|--------|
| Race condition order code (`count+1`) | `OrderService.java` | **DA FIX** — doi sang UUID |
| N+1 query department list | `DepartmentService.java` | Thap — so luong phong ban it |
| ChatController khong kiem tra quyen tao phong | `ChatController.java` | **DA FIX** — them auth check |
| `chat_repository_impl.dart` la stub cu khong dung | Flutter | Rat thap — khong anh huong runtime |
| 54 style hints `flutter analyze` | Nhieu file Flutter | Info only |
| `result` field trong warranty update gui trung | `staff_providers.dart` dong 148 | Rat thap |
| WebSocket mat subscription sau reconnect | `websocket_service.dart` | **DA FIX** — re-subscribe + backoff |

---

## Cau hinh can doi truoc khi deploy production

| Hang muc | Trang thai |
|----------|-----------|
| `BASE_URL` doi sang domain that | ❌ |
| `WS_URL` doi sang domain that | ❌ |
| `GOOGLE_MAPS_KEY` that | ❌ |
| `ZALO_APP_ID` that | ❌ |
| `JWT_SECRET` production | ✅ — phai set trong env var, khong con default yeu |
| `DB_PASSWORD` production | ✅ — phai set trong env var, khong con hardcoded |
| Cloudinary (upload anh) | ❌ |
| Firebase FCM (push notification) | ⚠️ — Code day du, can them google-services.json + service account JSON |
| Tach `backend/.env` (dev) va env var (prod) | ✅ — da tao `.env.example` |
| Khong commit secret vao git | ✅ — `.env` da gitignore |
