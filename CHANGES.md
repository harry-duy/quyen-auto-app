# Lịch sử thay đổi — Quyen Auto App

## [Unreleased] — Runtime Bugfixes

Các lỗi runtime phát hiện khi chạy thực tế sau khi login thành công.

### Flutter

#### `dashboard_screen.dart` — Crash khi render biểu đồ doanh thu
- **Lỗi**: `type 'double' is not a subtype of type 'List<dynamic>?'` tại `_RevenueChart`
- **Nguyên nhân**: Code dùng `data['monthlyRevenue']` — trường này là `BigDecimal` (tháng hiện tại, số đơn lẻ). Biểu đồ 6 tháng thực sự nằm ở `data['revenueChart']` (một `List`).
- **Fix**: Đổi sang `data['revenueChart']`, format nhãn tháng thành `T${item['month']}` (backend trả số nguyên 1–12).

#### `api_service.dart` — Nhập sai mật khẩu bị logout
- **Lỗi**: Login 401 (sai mật khẩu) khiến `_AuthInterceptor` cố refresh token rồi xóa hết token → bật ra màn hình login không rõ lý do
- **Fix**: Bỏ qua refresh logic cho tất cả endpoint bắt đầu bằng `auth/`

### Backend

#### `OrderService`, `QuotationService`, `WarrantyService` — 500 trên staff endpoints
- **Lỗi**: `/staff/orders`, `/staff/quotations`, `/staff/warranty` trả về 500
- **Nguyên nhân**: Các method đọc không có `@Transactional`. Repository mở/đóng session riêng; `.map(Response::from)` truy cập quan hệ `FetchType.LAZY` (customer, vehicle) sau khi session đã đóng → `LazyInitializationException`.
- **Fix**: Thêm `@Transactional(readOnly = true)` ở class level cho cả 3 service. Method ghi đã có `@Transactional` riêng, không ảnh hưởng.

#### `application-dev.yml` — MySQL password sai, Flyway validation fail
- **Fix**: Đúng password MySQL (`159357bapD`), thêm `spring.flyway.clean-on-validate-error: true` cho dev

#### `V4__seed_sample_data.sql` — SQL "subquery returns more than 1 row"
- **Lỗi**: `WHERE name LIKE '%5 Tấn%'` khớp cả 'Thùng Bảo Ôn 3.5 Tấn' lẫn 'Thùng Bảo Ôn 5 Tấn'
- **Fix**: Đổi thành exact match `= 'Thùng Bảo Ôn 5 Tấn'`; sửa BCrypt hash sang hash đúng của `admin123`

### Files thay đổi

| File | Loại | Thay đổi |
|------|------|----------|
| `lib/presentation/staff/dashboard_screen.dart` | Sửa | Dùng `revenueChart` thay `monthlyRevenue`, fix nhãn tháng |
| `lib/data/services/api_service.dart` | Sửa | Skip refresh cho `auth/` endpoints |
| `backend/.../order/service/OrderService.java` | Sửa | Thêm `@Transactional(readOnly = true)` |
| `backend/.../order/service/QuotationService.java` | Sửa | Thêm `@Transactional(readOnly = true)` |
| `backend/.../warranty/service/WarrantyService.java` | Sửa | Thêm `@Transactional(readOnly = true)` |
| `backend/src/main/resources/application-dev.yml` | Sửa | MySQL password + Flyway clean-on-validate |
| `backend/.../db/migration/V4__seed_sample_data.sql` | Sửa | Fix LIKE → exact match, fix BCrypt hash |

---

## [Unreleased] — Production hardening & deployment infrastructure

Toàn bộ các vấn đề bảo mật và hạ tầng được phát hiện trong quá trình đánh giá production.

### Bảo mật (Security)

#### JWT secret không còn có giá trị mặc định
- **Trước**: `application.yml` hardcode fallback `quyen-auto-default-jwt-secret-key-change-in-production-2024` → bất kỳ ai cũng có thể forge token nếu quên set env var
- **Sau**: `${JWT_SECRET}` không có fallback — app sẽ fail-fast khi khởi động nếu thiếu
- Dev profile tự override `app.jwt.secret` bằng giá trị riêng để không cần set env var khi develop

#### Swagger UI bị tắt trên production
- **Trước**: `/swagger-ui/**` và `/api-docs/**` luôn public, lộ toàn bộ API schema
- **Sau**: `application-prod.yml` set `springdoc.swagger-ui.enabled=false` và `springdoc.api-docs.enabled=false`
- Dev vẫn hoạt động bình thường

#### WebSocket CORS được giới hạn
- **Trước**: `WebSocketConfig` dùng `setAllowedOriginPatterns("*")` — bypass toàn bộ CORS
- **Sau**: Inject `${app.cors.allowed-origins}` và dùng cùng danh sách với HTTP CORS config

#### CORS allowed headers được giới hạn
- **Trước**: `setAllowedHeaders(List.of("*"))` — cho phép tất cả headers
- **Sau**: Chỉ cho phép `Authorization`, `Content-Type`, `Accept`, `X-Requested-With`

#### Access token expiry giảm trên production
- **Trước**: 24 giờ cố định cho cả dev và prod
- **Sau**: Prod override xuống 15 phút (`900000ms`) qua `application-prod.yml`; configurable qua `JWT_ACCESS_EXPIRY` env var

### Observability

#### Spring Boot Actuator
- Thêm `spring-boot-starter-actuator` vào `pom.xml`
- Expose `/actuator/health` và `/actuator/info` (public, không cần auth)
- `show-details: never` — không lộ thông tin nội bộ
- `/actuator/health` được thêm vào `SecurityConfig` permitAll list

### Infrastructure

#### Dockerfile (backend/Dockerfile)
- Multi-stage build: builder (JDK 17) + runtime (JRE 17 Alpine)
- Non-root user (`appuser`) để giảm attack surface
- Container-aware JVM flags (`-XX:+UseContainerSupport`, `-XX:MaxRAMPercentage=75.0`)
- `HEALTHCHECK` tích hợp sẵn gọi `/actuator/health`

#### Docker Compose
- **`docker-compose.yml`** — Dev: MySQL 8.0 + Redis 7 + Backend, tất cả có health check
- **`docker-compose.prod.yml`** — Production: đọc tất cả secrets từ env var, backend dùng pre-built image, có Nginx

#### Nginx (`nginx/nginx.conf`)
- Rate limiting: auth endpoints `10r/m`, API chung `30r/m`
- HTTP → HTTPS redirect (301)
- TLS 1.2/1.3 với modern cipher suites
- Security headers: `X-Frame-Options`, `X-Content-Type-Options`, `HSTS`
- WebSocket proxy với proper `Upgrade`/`Connection` headers

#### GitHub Actions CI/CD (`.github/workflows/ci.yml`)
- Trigger: push/PR vào `main`
- Job `backend`: spin up MySQL + Redis service containers → chạy tests → build JAR → upload artifact
- Job `docker`: build và push Docker image lên Docker Hub (chỉ khi merge vào main)
- Maven dependency cache để tăng tốc build

#### Test profile (`application-test.yml`)
- H2 in-memory (MODE=MySQL) thay vì MySQL thật
- Flyway tắt trong tests
- JWT secret có fallback an toàn cho CI

### Flutter

#### `.env.production.example`
- Template env file cho production build
- `BASE_URL` dùng `https://` và domain thật
- `WS_URL` dùng `wss://` (WebSocket over TLS)

### Files thay đổi

| File | Loại | Thay đổi |
|------|------|----------|
| `backend/src/main/resources/application.yml` | Sửa | Bỏ JWT default, thêm Actuator config |
| `backend/src/main/resources/application-dev.yml` | Sửa | Thêm JWT secret cho dev |
| `backend/src/main/resources/application-prod.yml` | Sửa | Tắt Swagger, giảm token expiry 15 min |
| `backend/src/main/resources/application-test.yml` | Mới | H2 in-memory profile cho CI |
| `backend/src/main/java/.../config/SecurityConfig.java` | Sửa | Thêm `/actuator/health` vào permitAll |
| `backend/src/main/java/.../config/CorsConfig.java` | Sửa | Giới hạn allowed headers |
| `backend/src/main/java/.../config/WebSocketConfig.java` | Sửa | CORS dùng configured origins thay vì `*` |
| `backend/pom.xml` | Sửa | Thêm `spring-boot-starter-actuator` |
| `backend/Dockerfile` | Mới | Multi-stage production build |
| `docker-compose.yml` | Mới | Dev environment (MySQL + Redis + Backend) |
| `docker-compose.prod.yml` | Mới | Production environment với Nginx |
| `nginx/nginx.conf` | Mới | Reverse proxy với SSL + rate limiting |
| `.github/workflows/ci.yml` | Mới | GitHub Actions CI/CD pipeline |
| `.env.production.example` | Mới | Flutter production env template |

### Hướng dẫn deploy production

**Yêu cầu bắt buộc** trước khi chạy `docker-compose.prod.yml`:

```bash
# 1. Tạo JWT secret (min 32 chars)
openssl rand -base64 48

# 2. Tạo file .env.prod
cat > .env.prod <<EOF
DB_ROOT_PASSWORD=<strong-root-password>
DB_NAME=quyen_auto
DB_USERNAME=quyenauto
DB_PASSWORD=<strong-db-password>
REDIS_PASSWORD=<strong-redis-password>
JWT_SECRET=<generated-above>
CORS_ORIGINS=https://yourdomain.com
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=<gmail-app-password>
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
APP_VERSION=latest
EOF

# 3. Đặt SSL certificate vào nginx/ssl/
# fullchain.pem + privkey.pem (từ Let's Encrypt hoặc CA)

# 4. Đặt firebase-service-account.json vào volume firebase_creds

# 5. Chạy
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

---

## [Unreleased] — Dữ liệu mẫu & Tài khoản test

Migration **`V4__seed_sample_data.sql`** — tất cả tài khoản dùng **mật khẩu: `admin123`**

### Tài khoản test

| Tên | SĐT | Role | Ghi chú |
|-----|-----|------|---------|
| Admin (đã có) | `0908109929` | ADMIN | Từ V1 |
| **Nguyễn Đức Tuần** | **`0909000001`** | **MANAGER** | Trưởng phòng Kinh Doanh |
| Nguyễn Văn Hùng | `0909000002` | STAFF | Kinh Doanh |
| Phạm Thị Lan | `0909000003` | STAFF | Kinh Doanh |
| Lê Quốc Bảo | `0909000004` | STAFF | Kỹ Thuật Sản Xuất |
| Trần Minh Đức | `0909000005` | STAFF | Kỹ Thuật Sản Xuất |
| Võ Thị Mai | `0909000006` | STAFF | Chăm Sóc KH |
| Nguyễn Thành Long | `0901111001` | CUSTOMER | KH mẫu |
| Trần Minh Khoa | `0901111002` | CUSTOMER | KH mẫu |
| Lê Thị Hoa | `0901111003` | CUSTOMER | KH mẫu |
| Phạm Văn Tài | `0901111004` | CUSTOMER | KH mẫu |
| Hoàng Thị Ngọc | `0901111005` | CUSTOMER | KH mẫu |

### Dữ liệu mẫu được tạo

- **4 phòng ban**: Kinh Doanh, Kỹ Thuật Sản Xuất, Chăm Sóc KH, Kế Toán
- **3 danh mục sản phẩm**: Thùng Bảo Ôn / Thùng Đông Lạnh / Thùng Composite
- **5 sản phẩm**: thùng 3.5T, 5T, đông lạnh Carrier, Thermo King, composite 1.5T
- **5 đại lý**: HCM, Bình Dương, Đồng Nai, Long An, Cần Thơ (có tọa độ GPS)
- **5 báo giá**: 3 PENDING + 1 QUOTED + 1 ACCEPTED
- **3 đơn hàng**: QA-2025-001 (CONFIRMED) / QA-2025-002 (IN_PRODUCTION) / QA-2025-003 (COMPLETED)
- **2 xe** + **1 yêu cầu bảo hành** PENDING
- **2 thông báo** mẫu cho tài khoản Tuần

---

## [Unreleased] — Management Hub cho MANAGER/ADMIN

Tab "Quản lý" mới trong staff app, chỉ hiển thị khi role là MANAGER hoặc ADMIN.

### Vấn đề trước đây
- `StaffMemberManagementScreen` và `DepartmentManagementScreen` đã tồn tại nhưng không có đường dẫn nào từ UI

### Thay đổi Frontend (Flutter)

#### `management_hub_screen.dart` (MỚI)
Màn hình hub tổng hợp, được nhúng trong IndexedStack của StaffHomeScreen:
- **User card**: Hiển thị tên, chức vụ và role badge (Admin/Manager/Staff)
- **Stats**: Tổng số nhân viên (kèm số đang hoạt động), số phòng ban — pull-to-refresh
- **Điều hướng**: Card "Quản lý nhân viên" → `StaffMemberManagementScreen`, Card "Phòng ban" → `DepartmentManagementScreen`

#### `staff_home_screen.dart` — Cập nhật
- Tabs và nav items được xây **động** dựa trên role người dùng:
  - **STAFF**: 6 tabs — Dashboard / Đơn hàng / Báo giá / Bảo hành / Chat / Tài khoản
  - **MANAGER / ADMIN**: 7 tabs — thêm tab "Quản lý" (icon `admin_panel_settings`) vào trước Tài khoản
- `safeIndex` clamp tự động khi tabs thay đổi (tránh out-of-bounds khi đổi tài khoản)

### Luồng hoạt động
```
Staff đăng nhập với role MANAGER/ADMIN
    ↓
StaffHomeScreen render 7 tabs (có tab Quản lý)
    ↓
Bấm tab "Quản lý" → ManagementHubScreen
    ↓
Bấm "Quản lý nhân viên" → push /management/staff → StaffMemberManagementScreen
Bấm "Phòng ban"         → push /management/departments → DepartmentManagementScreen
```

---

## [Unreleased] — Dev Script: chạy tất cả trong một lệnh

### Vấn đề trước đây
- Phải mở 3 terminal riêng, chạy thủ công từng service

### Thay đổi

#### `Makefile` (MỚI)
| Target | Lệnh tương đương |
|---|---|
| `make dev` | Mở Backend + Customer app + Staff app cùng lúc |
| `make backend` | `cd backend && ./mvnw spring-boot:run` |
| `make customer` | `flutter run --flavor customer -t lib/main.dart` |
| `make staff` | `flutter run --flavor staff -t lib/main_staff.dart` |
| `make build` | Build backend JAR (skip tests) |
| `make clean` | Xóa toàn bộ build artifacts |

#### `scripts/dev.ps1` (MỚI)
Script PowerShell được gọi bởi `make dev`:
- Nếu **Windows Terminal** (`wt.exe`) có sẵn → mở 3 tabs trong 1 cửa sổ
- Nếu không → mở 3 cửa sổ PowerShell riêng biệt

### Cách dùng
```bash
# Từ Git Bash hoặc terminal trong thư mục project
make dev
```
> **Lưu ý:** Chạy 2 Flutter app cùng lúc cần 2 thiết bị/emulator (1 cho Customer, 1 cho Staff).

---

## [Unreleased] — FCM Push Notification + WebSocket Real-time cho Staff

Triển khai hệ thống thông báo đẩy (push notification) và WebSocket real-time để nhân viên nhận thông báo ngay lập tức khi khách hàng gửi yêu cầu báo giá — không cần tự mở app refresh.

### Vấn đề trước đây

- Backend chỉ lưu notification vào DB, không gửi push ra ngoài app
- Staff phải **tự mở app và refresh** mới thấy có báo giá mới
- FCM token được lưu nhưng **không bao giờ sử dụng**
- WebSocket chỉ dùng cho chat, không broadcast notification
- Màn hình "Thông báo" chỉ là placeholder "Coming Soon"

### Thay đổi Backend

#### Dependency
- **`pom.xml`** — Thêm `firebase-admin:9.2.0` (Firebase Admin SDK cho Java)

#### Configuration
- **`application.yml`** — Thêm `app.firebase.credentials-path` config
- **`FirebaseConfig.java`** (MỚI) — Khởi tạo Firebase App từ service account JSON; graceful skip nếu chưa cấu hình
- **`QuyenAutoApplication.java`** — Thêm `@EnableAsync` cho async FCM push

#### Service
- **`FirebasePushService.java`** (MỚI) — Service gửi FCM push:
  - `sendToUser()` — Gửi push đến tất cả thiết bị của 1 user
  - `sendToUsers()` — Gửi push đến danh sách users
  - Tự động xóa stale FCM token khi thiết bị unregister
  - Chạy `@Async` — không block main thread
  - Android: HIGH priority + sound + FLUTTER_NOTIFICATION_CLICK
  - iOS: sound + badge

- **`NotificationService.notifyAllStaff()`** — Nâng cấp từ DB-only → 3 kênh:
  1. **DB** — Lưu notification record (như cũ)
  2. **WebSocket** — Push real-time đến `/user/{userId}/queue/notifications`
  3. **FCM** — Push notification đến thiết bị qua Firebase (async)

### Thay đổi Frontend (Flutter)

#### Data Layer
- **`push_notification_service.dart`** (MỚI) — Service quản lý FCM:
  - Khởi tạo Firebase + request permission
  - Đăng ký FCM token với server (`POST /notifications/fcm-token`)
  - Lắng nghe foreground + background + onOpenedApp messages
  - Auto-refresh token khi Firebase rotate
  - Cleanup token khi logout

- **`websocket_service.dart`** — Thêm `subscribeNotifications()` cho real-time

#### Providers
- **`notification_providers.dart`** — Viết lại hoàn toàn:
  - `pushNotificationServiceProvider` — DI cho FCM service
  - `NotificationListNotifier` — `AutoDisposeAsyncNotifier` thay vì `FutureProvider`:
    - Auto-polling mỗi 30 giây
    - Lắng nghe WebSocket real-time
    - Lắng nghe FCM foreground messages
    - `refresh()` method cho pull-to-refresh

- **`auth_providers.dart`** — Tích hợp FCM vào auth flow:
  - `_registerPushNotifications()` gọi sau login/register/zaloLogin
  - `logout()` gọi `removeToken()` trước khi clear session

#### Entry Points
- **`main.dart`** — Thêm `Firebase.initializeApp()` (customer app)
- **`main_staff.dart`** — Thêm `Firebase.initializeApp()` (staff app)

#### UI
- **`notification_screen.dart`** — Viết lại từ placeholder thành màn hình đầy đủ:
  - Pull-to-refresh
  - Icon + màu khác nhau theo type (báo giá/đơn hàng/bảo hành/chat)
  - Highlight unread (nền cam nhạt)
  - Time ago format (vừa xong / phút / giờ / ngày)
  - Empty state + error state

---

### Luồng thông báo mới

```
KH bấm "Gửi báo giá" trên app Customer
    ↓
POST /quotations → QuotationService.create()
    ↓
notifyAllStaff() chạy 3 kênh song song:
    ├── [1] INSERT notification vào DB ✅
    ├── [2] WebSocket → /user/{staffId}/queue/notifications ✅
    └── [3] FCM push → Firebase → thiết bị staff (async) ✅
    ↓
Staff nhận thông báo:
    ├── Đang mở app → WebSocket real-time, list tự refresh
    ├── App ở background → FCM push notification hiện trên thanh trạng thái
    └── App đã tắt → FCM push đánh thức thiết bị hiện notification
```

### Cấu hình cần thiết

#### Backend
1. Tạo Firebase project tại https://console.firebase.google.com
2. Tải file **service account JSON** (Project Settings → Service Accounts → Generate New Private Key)
3. Đặt file vào server và set env: `FIREBASE_CREDENTIALS_PATH=/path/to/firebase-service-account.json`

#### Flutter
1. Thêm `google-services.json` (Android) vào `android/app/`
2. Thêm `GoogleService-Info.plist` (iOS) vào `ios/Runner/`
3. Cả hai file lấy từ Firebase Console → Project Settings → Your Apps

---

## [Unreleased] — Tạo báo giá nâng cao

Thiết kế lại toàn bộ form tạo báo giá theo mẫu Excel thực tế của công ty (file `Tạo báo giá.xlsx`).

### Thay đổi Backend

#### Migration
- **`V2__quotation_extended.sql`** — Thêm 9 cột mới vào bảng `quotations`:
  - `vehicle_model` VARCHAR(100) — Kiểu loại xe
  - `quantity` INT DEFAULT 1 — Số lượng
  - `chassis_width` INT — Rộng chassis (mm)
  - `box_code` VARCHAR(20) — Mã thùng
  - `box_type` VARCHAR(30) — Loại (F2LB, L, S...)
  - `ac_type` VARCHAR(20) — Loại máy lạnh (TN, KL...)
  - `ac_model` VARCHAR(100) — Model máy lạnh
  - `inner_wall_insulated` BOOLEAN — Vách trong tải kín
  - `specifications` JSON — Toàn bộ thông số kỹ thuật (phụ kiện, foam, option)

#### Entity
- **`Quotation.java`** — Thêm các field tương ứng với cột mới

#### DTO
- **`CreateQuotationRequest.java`** — Thêm các field mới; giữ `weightRange`, `cargoType`, `note` để tương thích ngược
- **`QuotationResponse.java`** — Expose đầy đủ các field mới trong response

#### Service
- **`QuotationService.java`** — Cập nhật `create()` để populate các field mới khi lưu Quotation

---

### Thay đổi Frontend (Flutter)

#### Data Layer
- **`quotation_request.dart`** — Viết lại thành plain Dart class (bỏ `@JsonSerializable`); thêm các field mới; `toJson()` viết tay
- **`quotation_request.g.dart`** — Vô hiệu hóa (không còn dùng code generation)
- **`order_repository.dart`** — Đơn giản hóa interface: `createQuotation(QuotationRequest)` thay vì 5 named params
- **`order_repository_impl.dart`** — Cập nhật theo interface mới
- **`order_providers.dart`** — `QuotationNotifier.submit()` nhận `QuotationRequest` trực tiếp

#### UI
- **`quotation_form_screen.dart`** — Thiết kế lại hoàn toàn:
  - **Bước 1 — Thông tin cơ bản**: Sản phẩm, kiểu loại xe, số lượng, rộng chassis, kích thước thùng (phủ bì + lọt lòng), mã thùng, loại, máy lạnh, vách trong tải kín
  - **Bước 2 — Phụ kiện & trang bị**: Loại sàn, yêu cầu sàn, khung trụ, cửa hông phụ/tài (có nhập kích thước), đèn hông, baga cabin, thang leo, ống OXY đầu/hông, thiết bị 1-2-3 (autocomplete)
  - **Bước 3 — Thông số kỹ thuật**: Foam (mm) theo từng vị trí: sàn/đầu/hông/nóc/cửa — có giá trị mặc định tiêu chuẩn
  - **Bước 4 — Tùy chọn & ghi chú**: Lòn hơi, part bảo vệ, nắp bầu hơi, nắp bình, thùng vết; ghi chú thêm
  - Dùng `Stepper` widget để điều hướng 4 bước
  - Tất cả specifications được đóng gói thành JSON object khi gửi lên server

---

## [Unreleased] — Giao diện staff + theo dõi liên hệ KH

Triển khai giao diện quản lý báo giá dành cho nhân viên (staff), sửa bug khiến staff không nhận được thông tin báo giá từ khách hàng, và thêm chức năng theo dõi liên hệ khách hàng.

### Root Cause: Staff không nhận báo giá

1. **URL sai**: Flutter gọi `POST /orders/quotation` nhưng controller chỉ có `POST /quotations` → sửa `ApiConstants.createQuotation = 'quotations'`
2. **Parse response sai**: Flutter parse kết quả như `OrderResponse` thay vì `QuotationResponse` → sửa `order_repository_impl.dart`
3. **Không gửi thông báo**: Thiếu logic broadcast notification đến staff → thêm `notifyAllStaff()` trong `QuotationService.create()`

---

### Thay đổi Backend

#### Migration
- **`V3__quotation_contact_tracking.sql`** — Thêm 2 cột vào `quotations`:
  - `contacted_by` BIGINT FK → `users.id` — Nhân viên đã liên hệ
  - `contacted_at` TIMESTAMP — Thời điểm liên hệ

#### Entity
- **`Quotation.java`** — Thêm `contactedBy` (ManyToOne User) và `contactedAt` (LocalDateTime)

#### DTO
- **`QuotationResponse.java`** — Thêm `customerPhone`, `contactedById`, `contactedByName`, `contactedAt`

#### Notification
- **`NotificationService.notifyAllStaff()`** — Gửi notification đến tất cả user có role STAFF/MANAGER đang active

#### Service
- **`QuotationService.create()`** — Gọi `notifyAllStaff()` sau khi lưu yêu cầu báo giá mới
- **`QuotationService.markContacted()`** — Đánh dấu nhân viên đã liên hệ; idempotent (bấm lại không ghi đè)

#### Controller
- **`QuotationController`** — Thêm `PATCH /staff/quotations/{id}/contact` để đánh dấu đã liên hệ

---

### Thay đổi Frontend (Flutter)

#### Data Layer
- **`ApiService.patch()`** — Thêm method HTTP PATCH vào service wrapper
- **`ApiConstants`** — Thêm `staffQuotationContact`, `myQuotations`; sửa `createQuotation = 'quotations'`
- **`quotation_response.dart`** (MỚI) — `StaffQuotationResponse` plain Dart class với toàn bộ field kể cả contact tracking; manual `fromJson`
- **`staff_providers.dart`**:
  - `staffQuotationStatusFilter` — filter state cho tab báo giá
  - `staffQuotationListProvider` — dùng `StaffQuotationResponse`, xử lý cả `PageResponse.content` và plain list
  - `staffUncontactedCountProvider` — đếm PENDING chưa liên hệ (dùng cho badge)
  - `StaffActionsNotifier.markQuotationContacted()` — gọi PATCH `/contact`
  - `StaffActionsNotifier.approveQuotation()` — sửa field name: `quotedPrice` + `staffNote`; chuyển từ PUT → PATCH

#### UI
- **`quotation_list_staff_screen.dart`** (MỚI) — Màn hình quản lý báo giá:
  - Filter chips: Tất cả / Chờ xử lý / Đã báo giá / Đã chốt / Từ chối
  - Card theo từng yêu cầu: info KH, SĐT, loại xe, loại thùng, kích thước, tải trọng, ghi chú, giá đã báo
  - Banner cảnh báo cam khi PENDING chưa có ai liên hệ
  - Banner xanh lá + tên NV + giờ khi đã liên hệ
  - Button "Đã liên hệ KH" (chỉ hiện khi PENDING + chưa liên hệ) → gọi API + refresh
  - Button "Gửi báo giá" (khi PENDING) → dialog nhập giá + ghi chú
  - Pull-to-refresh
- **`quotation_approval_screen.dart`** — Re-export `quotation_list_staff_screen.dart` (đã thay thế)
- **`staff_home_screen.dart`** — Thêm tab "Báo giá" (index 2) với badge đỏ đếm PENDING chưa liên hệ

---

### Luồng hoạt động

```
KH tạo báo giá
    ↓
POST /quotations (Flutter → Backend)
    ↓
Backend lưu DB + notifyAllStaff()
    ↓
Tất cả STAFF/MANAGER nhận notification (badge +1 trên tab Báo giá)
    ↓
Staff A mở tab Báo giá → thấy card có banner cam "Chưa có NV liên hệ"
    ↓
Bấm "Đã liên hệ KH" → PATCH /staff/quotations/{id}/contact
    ↓
Banner chuyển xanh lá "Staff A đã liên hệ • dd/MM HH:mm"
Badge về 0, Staff B cũng thấy trạng thái cập nhật (pull refresh)
    ↓
Bấm "Gửi báo giá" → PATCH /staff/quotations/{id}/approve
Status → QUOTED, KH được thông báo qua kênh khác
```

---

### Cấu trúc `specifications` JSON

```json
{
  "dimensions": {
    "outer": { "length": 4450, "width": 1950, "height": 1950 },
    "inner": { "length": 4270, "width": 1810, "height": 1780 }
  },
  "floor": { "type": "C", "requirement": "Nhôm chống trượt" },
  "pillarFrame": "INOX",
  "sideDoorPassenger": { "enabled": true, "width": 750, "height": 1550 },
  "sideDoorDriver": true,
  "sideLight": { "enabled": false, "qty": 0 },
  "cabinRack": { "enabled": true, "qty": 1 },
  "ladder": { "enabled": true, "qty": 1 },
  "oxyPipeFront": true,
  "oxyPipeSide": true,
  "equipments": ["Máy Oxy: RT90-M + ZLE-50LA", "Bửng nâng hạ DLC3"],
  "foam": { "floor": 60, "front": 60, "side": 60, "roof": 75, "door": 60 },
  "options": {
    "airTubeStandard": { "enabled": false, "qty": 0 },
    "airTubeHorizontal": { "enabled": false, "qty": 0 },
    "protectionPart": { "enabled": false, "qty": 0 },
    "airChamberCap": { "enabled": false, "qty": 0 },
    "tankCap": { "enabled": false, "qty": 0 },
    "traceCargo": { "enabled": false, "qty": 0 }
  }
}
```
