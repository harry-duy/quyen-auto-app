# Quyen Auto Mobile System

Hệ thống quản lý kinh doanh xe thùng — gồm 2 ứng dụng Flutter (Khách hàng + Nhân viên) và 1 backend Spring Boot.

## Kiến trúc

```
quyen_auto_app/
├── lib/                    # Flutter frontend (Clean Architecture + Riverpod)
│   ├── core/              # Config, constants, DI, router, theme
│   ├── data/              # Repositories impl, services, models
│   ├── domain/            # Entities, repository interfaces
│   └── presentation/      # Screens, widgets (auth, home, order, chat, staff...)
├── backend/               # Spring Boot 3.4 (Java 17)
│   └── src/main/java/com/quyenauto/
│       ├── auth/          # JWT authentication, login, register
│       ├── chat/          # WebSocket STOMP chat
│       ├── order/         # Orders, quotations
│       ├── payment/       # VNPay integration
│       ├── product/       # Product catalogue
│       ├── report/        # Dashboard & revenue reports
│       ├── warranty/      # Warranty management
│       └── config/        # Security, CORS, rate limiting
└── android/               # Android config (2 flavors: customer, staff)
```

## Chạy project

### Prerequisites
- Flutter SDK >= 3.10
- Java 17+
- MySQL 8.0+
- Redis 7+

### Backend
```bash
cd backend
cp .env.example .env   # Cấu hình DB, Redis, JWT secret
./mvnw spring-boot:run
```

### Flutter (Customer app)
```bash
flutter run --flavor customer -t lib/main.dart
```

### Flutter (Staff app)
```bash
flutter run --flavor staff -t lib/main_staff.dart
```

## Tài khoản mặc định (dev)
- **Admin:** 0908109929 / admin123
- ⚠️ Phải đổi mật khẩu ngay khi deploy production

---

## CHANGELOG

### v1.1.0 — Security & Feature Enhancement (2026-05-12)

#### 🔒 Bảo mật

| Thay đổi | File | Mô tả |
|----------|------|--------|
| Rate Limiting | `config/RateLimitConfig.java` | Auth: 5 req/phút/IP, Global: 100 req/phút/IP (Bucket4j) |
| Security Headers | `config/SecurityHeadersConfig.java` | HSTS, X-Frame-Options DENY, X-XSS-Protection, no-cache |
| JWT hardening | `auth/security/JwtService.java` | Reject default secret trong production, enforce min 32 chars |
| Account Lockout | `auth/service/LoginAttemptService.java` | Khóa 15 phút sau 5 lần login sai |
| Token TTL giảm | `application.yml` | Access token: 24h → 1h (bảo mật hơn) |
| Production SSL | `application-prod.yml` | SSL config, Redis password required, leak detection |

#### 💳 Thanh toán VNPay

| File | Mô tả |
|------|--------|
| `payment/service/VNPayService.java` | Tạo payment URL, verify callback HMAC-SHA512 |
| `payment/controller/PaymentController.java` | POST /payment/create, GET /payment/callback |
| `payment/dto/PaymentRequest.java` | Validation: orderId required, amount min 10,000₫ |
| `lib/presentation/order/payment_screen.dart` | WebView thanh toán + dialog success/fail |

#### 💬 Chat hoàn thiện

| File | Mô tả |
|------|--------|
| `lib/data/repositories/chat_repository_impl.dart` | REST history + WebSocket realtime subscribe |
| `lib/presentation/chat/chat_screen.dart` | UI chat bubbles, date separator, read receipts |

#### 🌐 UX Improvements

| File | Mô tả |
|------|--------|
| `lib/presentation/widgets/connectivity_banner.dart` | Banner cảnh báo khi mất kết nối mạng |
| `lib/main.dart`, `lib/main_staff.dart` | Wrap ConnectivityBanner cho cả 2 app |
| `lib/core/utils/validators.dart` | Thêm: strongPassword, fullName, plateNumber, sanitize XSS |
| `lib/core/constants/api_constants.dart` | Thêm payment endpoints |
| `lib/core/router/app_router.dart` | Thêm /payment route |

#### 📋 DevOps

| File | Mô tả |
|------|--------|
| `backend/.env.example` | Template đầy đủ cho production deployment |
| `backend/pom.xml` | Thêm dependency: bucket4j-core 8.10.1 |

---

### v1.0.0 — Initial Release (2026-05-10)

- Flutter app (Customer): Login, Catalogue, Orders, Warranty, Profile, Chat
- Flutter app (Staff): Dashboard, Order management, Quotation approval, Warranty
- Spring Boot backend: Full REST API + WebSocket
- JWT auth with refresh token rotation
- Offline-first product caching (Hive)
- Realtime order status via STOMP WebSocket
- Flyway database migrations
- Unit tests (45 Flutter + 1 integration backend)

---

## Cấu hình Production

### Biến môi trường bắt buộc

| Variable | Mô tả |
|----------|--------|
| `JWT_SECRET` | Random string >= 64 ký tự |
| `DB_HOST`, `DB_PASSWORD` | MySQL credentials |
| `REDIS_HOST`, `REDIS_PASSWORD` | Redis credentials |
| `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET` | VNPay merchant config |

### Checklist trước go-live

- [ ] Đổi JWT_SECRET (không dùng default)
- [ ] Đổi mật khẩu admin mặc định
- [ ] Bật SSL (`SSL_ENABLED=true`)
- [ ] Cấu hình Redis password
- [ ] Đăng ký VNPay merchant account
- [ ] Setup Firebase project cho FCM push notification
- [ ] Cấu hình Cloudinary cho image upload
- [ ] Test rate limiting hoạt động đúng
- [ ] Setup database backup schedule
