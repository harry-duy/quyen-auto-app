# Quyen Auto App

Hệ thống quản lý đặt hàng thùng xe tải — Flutter (Android) + Spring Boot backend.

---

## Setup lần đầu (cho teammate mới)

> Yêu cầu cài sẵn: **Java 17+**, **Flutter 3.x**, **MySQL 8.0**

### Bước 1 — Clone repo
```bash
git clone <repo-url>
cd quyen_auto_app
flutter pub get
```

### Bước 2 — Flutter `.env`
```bash
cp .env.example .env
# Nếu chạy thiết bị thật: đổi 10.0.2.2 thành IP máy tính trong mạng LAN
```

### Bước 3 — Backend `.env`
```bash
cp backend/.env.example backend/.env
# Mở backend/.env, điền DB_PASSWORD = password MySQL của máy bạn
```

### Bước 4 — Firebase `google-services.json`
Nhận 3 file từ team lead (hoặc download từ Firebase Console → Project `quyen-auto`):
```
android/app/google-services.json
android/app/src/customer/google-services.json
android/app/src/staff/google-services.json
```
> Không có 3 file này thì app **build không được**. File `backend/firebase-service-account.json` có thể bỏ qua khi dev.

### Bước 5 — Chạy
```bash
make dev   # Mở backend + 2 Flutter app cùng lúc
```

---

## Chạy nhanh

```bash
make dev          # Mở 3 cửa sổ: Backend + Customer app + Staff app
make backend      # Chỉ backend
make customer     # Chỉ customer app
make staff        # Chỉ staff app
make build        # Build backend JAR
make clean        # Dọn build artifacts
```

> Yêu cầu: 2 thiết bị/emulator kết nối để chạy cả 2 Flutter app cùng lúc.

---

## Tài khoản test

> **Mật khẩu chung:** `admin123`

### Staff App

| Tên | Số điện thoại | Role | Phòng ban |
|-----|--------------|------|-----------|
| Admin | `0909000000` | ADMIN | Ban Giám Đốc |
| Nguyễn Đức Tuần | `0909000001` | MANAGER | Kinh Doanh |
| Nguyễn Văn Hùng | `0909000002` | STAFF | Kinh Doanh |
| Phạm Thị Lan | `0909000003` | STAFF | Kinh Doanh |
| Lê Quốc Bảo | `0909000004` | STAFF | Kỹ Thuật Sản Xuất |
| Trần Minh Đức | `0909000005` | STAFF | Kỹ Thuật Sản Xuất |
| Võ Thị Mai | `0909000006` | STAFF | Chăm Sóc KH |

> ADMIN và MANAGER thấy tab **Quản lý** (quản lý nhân viên & phòng ban).

### Customer App

| Tên | Số điện thoại |
|-----|--------------|
| Nguyễn Thành Long | `0901111001` |
| Trần Minh Khoa | `0901111002` |
| Lê Thị Hoa | `0901111003` |
| Phạm Văn Tài | `0901111004` |
| Hoàng Thị Ngọc | `0901111005` |

---

## Cấu trúc project

```
quyen_auto_app/
├── lib/                        # Flutter source
│   ├── main.dart               # Entry point — Customer app
│   ├── main_staff.dart         # Entry point — Staff app
│   ├── core/
│   │   ├── constants/          # AppColors, ApiConstants
│   │   ├── di/                 # Riverpod providers
│   │   ├── router/             # GoRouter (app_router, staff_router)
│   │   └── theme/
│   ├── data/
│   │   ├── models/             # JSON DTOs
│   │   └── services/           # ApiService, WebSocketService, PushNotificationService
│   ├── domain/
│   │   └── entities/           # User, Order, Quotation...
│   └── presentation/
│       ├── auth/               # Login, Register
│       ├── staff/              # Staff app screens
│       └── ...                 # Customer screens
├── backend/                    # Spring Boot 3 + MySQL
│   └── src/main/resources/
│       └── db/migration/       # Flyway V1–V4
├── android/
│   └── app/src/
│       ├── customer/           # google-services.json (Customer)
│       └── staff/              # google-services.json (Staff)
├── Makefile
└── scripts/dev.ps1
```

---

## Backend

- **URL:** `http://localhost:8080/api/v1`
- **DB:** MySQL `quyen_auto` (tự tạo khi start)
- **Docs:** `http://localhost:8080/api/v1/swagger-ui.html`
- **Firebase:** đặt `backend/firebase-service-account.json` (gitignored)

### Cấu hình môi trường

```bash
# Bắt buộc khi deploy production
JWT_SECRET=<chuỗi >= 32 ký tự>
CORS_ORIGINS=https://yourdomain.com

# Tùy chọn
FIREBASE_CREDENTIALS_PATH=firebase-service-account.json
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=app-password
```

---

## Android Build Flavors

| Flavor | Package | Entry point |
|--------|---------|-------------|
| `customer` | `com.quyenauto.customer` | `lib/main.dart` |
| `staff` | `com.quyenauto.staff` | `lib/main_staff.dart` |

```bash
# Build release APK
flutter build apk --flavor customer -t lib/main.dart
flutter build apk --flavor staff   -t lib/main_staff.dart
```
