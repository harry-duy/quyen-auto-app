# Quyen Auto App - Notes da fix

File nay ghi lai nhung loi da xu ly va cach chay hien tai de nguoi khac tiep tuc project de nam nhanh tinh trang.

## 1. Loi build APK / Gradle

Da fix cac loi asset bi thieu khi build Flutter:

- Tao lai cac folder asset:
  - `assets/`
  - `assets/images/`
  - `assets/icons/`
  - `assets/fonts/`
- Tao file `.env`.
- Sua cau hinh asset de Flutter bundle khong bao loi.
- Go cau hinh Android flavor bi sai lam Gradle build xong nhung Flutter khong tim thay APK.

Ket qua:

- `flutter build apk --debug` da build duoc APK.
- APK nam o:
  - `build/app/outputs/flutter-apk/app-debug.apk`

## 2. Loi dang nhap theo role

Da sua luong login:

- User thuong vao man hinh customer:
  - `/home`
- Staff/Admin vao man hinh nhan vien:
  - `/staff/home`

Da sua cach doc response login tu backend:

- `accessToken` va `refreshToken` nam truc tiep trong `data`.
- Thong tin user nam trong `data.user`.
- App lay role tu `data.user.role`.

Tai khoan test da login duoc:

```text
phone: 0908109929
password: admin123
role: ADMIN
```

## 3. Cau hinh database MySQL

Backend dang dung MySQL remote:

```text
host: 192.168.0.95
port: 3306
database: quyen_auto
```

File cau hinh backend da duoc chinh de doc bien moi truong:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`

Lenh chay backend mau:

```powershell
cd "Z:\Thuc tap\quyen-auto-app\backend"

$env:DB_URL="jdbc:mysql://192.168.0.95:3306/quyen_auto?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh&createDatabaseIfNotExist=true"
$env:DB_USERNAME="quyen_user"
$env:DB_PASSWORD="QuyenAuto123"

.\mvnw.cmd spring-boot:run
```

Backend chi chay duoc neu MySQL remote dang mo va port `3306` truy cap duoc.

Kiem tra nhanh:

```powershell
Test-NetConnection 192.168.0.95 -Port 3306
```

Neu `TcpTestSucceeded` la `False` thi loi nam o database/mang/firewall/IP, khong phai Flutter.

## 4. Flyway migration / password admin

Da them migration moi de sua password admin ma khong sua migration cu:

```text
backend/src/main/resources/db/migration/V2__fix_admin_password.sql
```

Ly do:

- Khong nen sua file migration `V1__init_schema.sql` sau khi database da chay Flyway.
- Sua V1 se gay loi checksum mismatch.
- Cach dung la them migration moi `V2`.

## 5. Loi backend khong chay do port 8080

Neu backend bao:

```text
Port 8080 was already in use
```

Thi port `8080` dang bi process khac chiem.

Lenh tat process dang nghe port `8080`:

```powershell
$pid8080 = (Get-NetTCPConnection -LocalPort 8080 -State Listen).OwningProcess
Stop-Process -Id $pid8080 -Force
```

Sau do chay lai backend.

Backend chay dung khi thay log:

```text
Tomcat started on port 8080
Started QuyenAutoApplication
```

## 6. Loi app timeout khi dang nhap

Thong bao tren app:

```text
Ket noi qua thoi gian. Vui long kiem tra mang va thu lai.
```

Nguyen nhan thuong gap:

- Backend chua chay tren port `8080`.
- MySQL remote khong vao duoc nen backend khong start.
- Emulator goi `10.0.2.2:8080`, nhung tren may Windows khong co backend dang listen.

Kiem tra backend local:

```powershell
Test-NetConnection 127.0.0.1 -Port 8080
```

Neu `TcpTestSucceeded` la `False`, app Flutter se timeout khi login.

## 7. Cau hinh API Flutter

File `.env` hien tai:

```env
BASE_URL=http://10.0.2.2:8080/api/v1/
WS_URL=ws://10.0.2.2:8080/api/v1/ws
GOOGLE_MAPS_KEY=your_key_here
ZALO_APP_ID=your_zalo_app_id
```

Ghi chu:

- `10.0.2.2` la dia chi emulator Android dung de tro ve may Windows host.
- Neu chay tren dien thoai that, khong dung `10.0.2.2`.
- Khi chay tren dien thoai that, doi `BASE_URL` sang IP LAN cua may chay backend, vi du:

```env
BASE_URL=http://192.168.0.xxx:8080/api/v1/
WS_URL=ws://192.168.0.xxx:8080/api/v1/ws
```

## 8. Loi WebSocket `/ws`

Loi cu:

```text
WS Error: WebSocketException:
Connection to 'http://10.0.2.2:8080/api/v1/ws#'
was not upgraded to websocket, HTTP status code: 400
```

Nguyen nhan:

- Flutter dung raw WebSocket qua `stomp_dart_client`.
- Backend truoc do khai bao `/ws` bang SockJS.
- Hai ben khong khop nen server tra `400`.

Da sua backend WebSocket config sang raw WebSocket:

```java
registry.addEndpoint("/ws")
        .setAllowedOriginPatterns("*");
```

Sau khi sua phai restart backend thi moi co hieu luc.

## 9. Loi loop khi bam Home / San pham noi bat / Bao hanh xe

Nguyen nhan:

- `HomeScreen` dang dung `IndexedStack` de hien 5 tab:
  - Home
  - Catalogue
  - Don hang
  - Bao hanh
  - Tai khoan
- Mot so nut lai dieu huong den route gia:
  - `/home/catalogue`
  - `/home/orders`
  - `/home/warranty`
- Cac route nay khong duoc khai bao trong `GoRouter`, nen de gay redirect/vong ve Home.

Da sua:

- Nut `San pham noi bat > Xem tat ca` chuyen sang tab Catalogue.
- Nut `Bao hanh xe` chuyen sang tab Bao hanh.
- Nut `Don hang cua toi` chuyen sang tab Don hang.
- Nut `Dat hang ngay` chuyen sang tab Catalogue.
- Sau khi gui bao gia, nut `Xem don hang` quay ve Home va mo tab Don hang.

Khong con dung cac route gia:

```text
/home/catalogue
/home/orders
/home/warranty
/home/profile
```

## 10. Lenh chay app

## 10. Sua endpoint Flutter khop backend

Da sua cac endpoint trong Flutter de khop voi backend hien tai. Viec nay khong dung den database, chi sua code client/API constants.

Da sua:

```text
orders/my                 -> orders
orders/quotation          -> quotations
warranty/requests         -> warranty
notifications/{id}/read   -> notifications/mark-read
departments               -> admin/departments
departments/{id}          -> admin/departments/{id}
staff/warranty/{id}       -> staff/warranty/{id}/result
reports/dashboard         -> staff/dashboard
```

Ly do:

- Flutter truoc do khai bao mot so endpoint khong ton tai trong backend.
- Khi bam cac chuc nang nhu don hang, bao gia, thong bao, bao hanh, staff management co the bi loi 404/405 hoac parse sai response.

## 11. Them PATCH vao ApiService

Backend dung `@PatchMapping` cho nhieu action staff, nhung Flutter truoc do chi co `get/post/put/delete`.

Da them:

```dart
Future<ServiceResult<T>> patch<T>(...)
```

Nhung action da doi sang `PATCH`:

- Cap nhat trang thai don hang staff.
- Duyet bao gia staff.
- Phan cong bao hanh.
- Cap nhat ket qua bao hanh.
- Bat/tat tai khoan nhan vien.

## 12. Sua mapper PageResponse

Backend tra nhieu danh sach theo dang phan trang:

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 0,
  "totalPages": 0
}
```

Flutter truoc do lai cast truc tiep `json as List`, de gay loi khi API tra object phan trang.

Da them helper lay `content` neu co:

```dart
List<dynamic> _items(dynamic json) {
  if (json is Map<String, dynamic> && json['content'] is List) {
    return json['content'] as List;
  }
  return json as List;
}
```

Da ap dung cho:

- Customer orders.
- Staff orders.
- Staff quotations.
- Staff warranty.
- Notifications.
- Staff members.

## 13. Sua payload staff action khop DTO backend

Da sua payload de khop DTO backend:

### Duyet bao gia

Cu:

```json
{
  "price": 1000000,
  "note": "..."
}
```

Moi:

```json
{
  "quotedPrice": 1000000,
  "staffNote": "..."
}
```

### Phan cong bao hanh

Cu:

```json
{
  "technician": "Nguyen Van A"
}
```

Moi:

```json
{
  "technicianId": 1
}
```

Man phan cong bao hanh da doi label tu `Ten ky thuat vien` sang `ID ky thuat vien`, va input dang so.

### Cap nhat ket qua bao hanh

Moi:

```json
{
  "status": "RESOLVED",
  "result": "RESOLVED",
  "note": "..."
}
```

## 14. Sua tao bao gia parse response

Backend `POST /quotations` tra ve `QuotationResponse`, khong phai `OrderResponse`.

Da sua Flutter:

- Tao bao gia parse `QuotationResponse`.
- Map tam sang entity `Order` de UI hien duoc thong tin can thiet sau khi gui bao gia.

## 15. Sua request bao hanh

Backend DTO tao bao hanh can field:

```json
{
  "vehicleId": 1,
  "issueDescription": "..."
}
```

Flutter truoc do gui:

```json
{
  "vehicleId": 1,
  "issue": "..."
}
```

Da doi `issue` thanh `issueDescription`.

## 16. Lenh chay app

Chay backend truoc:

```powershell
cd "Z:\Thuc tap\quyen-auto-app\backend"
$env:DB_URL="jdbc:mysql://192.168.0.95:3306/quyen_auto?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh&createDatabaseIfNotExist=true"
$env:DB_USERNAME="quyen_user"
$env:DB_PASSWORD="QuyenAuto123"
.\mvnw.cmd spring-boot:run
```

Sau khi backend len port `8080`, chay Flutter:

```powershell
cd "Z:\Thuc tap\quyen-auto-app"
C:\Users\admin\Downloads\flutter\bin\flutter.bat run
```

Neu da co `flutter` trong PATH thi co the dung:

```powershell
flutter run
```

## 17. Tinh trang kiem tra

Da kiem tra:

- Backend login API tra `200 OK`.
- Tai khoan admin login duoc.
- `flutter analyze` khong co loi compile.
- Chi con cac lint info cu, khong anh huong chay app.
- `flutter test` da pass:
  - `45/45 tests passed`.

---

## SESSION 2 — Cai dat local + Fix bug (2026-05-11)

### Moi truong chay local

Backend dang chay local voi MySQL:

```text
host: localhost:3306
database: quyen_auto
username: root
password: 159357bapD
```

File da chinh: `backend/src/main/resources/application-dev.yml`

Da xoa cau hinh Redis khoi `application-dev.yml` vi may local khong cai Redis.

Da them `@ConditionalOnProperty` vao `RedisConfig.java` de tranh loi bean khi Redis khong co:

```java
@ConditionalOnProperty(name = "spring.data.redis.host", matchIfMissing = false)
public class RedisConfig { ... }
```

Da them `exclude = {RedisAutoConfiguration.class}` vao `QuyenAutoApplication.java`:

```java
@SpringBootApplication(exclude = {RedisAutoConfiguration.class})
```

### Tai khoan test xac nhan chay duoc

| Vai tro | So dien thoai | Mat khau |
|---------|--------------|---------|
| ADMIN   | 0908109929   | admin123 |
| CUSTOMER | 0937217013  | 123456   |

Mat khau admin trong `V1__init_schema.sql` truoc do dung sai hash (hash mau, khong phai `admin123`).
Da cap nhat bang hash BCrypt chinh xac:

```text
$2a$10$aNO8hs81s1F4XPDzTunhCOpBCJwO/GU2tIaqo/E0nX5mApMtytvyO
```

### Cach chay backend local

```powershell
cd "C:\Users\Admin\StudioProjects\quyen_auto_app\backend"
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev
```

Backend len dung khi thay:

```text
Tomcat started on port 8080
Started QuyenAutoApplication
```

### Cach chay Flutter tren emulator

Dung Android Studio: chon device `emulator-5556`, nhan nut Run (Shift+F10).

Neu man hinh emulator hien den (black screen), co the emulator dang sleep.
Nhan phim Home tren emulator de wake up.

Kiem tra emulator co dang chay app khong:

```powershell
& "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe" -s emulator-5556 shell "pidof com.quyenauto.quyen_auto_app"
```

Neu co PID tra ve = app dang chay.

Chup anh man hinh emulator:

```powershell
$adb = "C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5556 shell "screencap -p /sdcard/screenshot.png"
& $adb -s emulator-5556 pull /sdcard/screenshot.png "C:\screenshot.png"
```

### Ghi chu Flutter run bi "Lost connection" tren Windows PowerShell

```text
Failed to connect to the VM observatory service
java.net.ConnectException: Connection refused
```

Day la loi debug port forwarding tren Windows, KHONG phai loi app.
App van duoc cai dat va chay binh thuong tren emulator.
Khac phuc: dung Android Studio thay vi `flutter run` trong terminal.

---

## SESSION 2 — Kiem tra toan bo va fix bug (flutter analyze + manual review)

Da chay `flutter analyze` va kiem tra thu cong toan bo project.
Ket qua: 54 issues nhung tat ca deu la `info` level (style, khong anh huong runtime).

### Cac loi nghiem trong da fix (commit ac0099e)

#### 1. WebSocket chat khong bao gio nhan duoc tin nhan

- **File**: `lib/data/services/websocket_service.dart`
- **Loi**: Flutter subscribe `/topic/room/{roomId}` nhung backend broadcast `/topic/chat.room.{roomId}`
- **Fix**: Doi topic dung voi backend

```dart
// Cu (sai):
final dest = '/topic/room/$roomId';

// Moi (dung):
final dest = '/topic/chat.room.$roomId';
```

#### 2. toggleStaffActive tra loi 405 Method Not Allowed

- **File**: `lib/core/di/management_providers.dart`
- **Loi**: Flutter dung `PUT` nhung backend khai bao `@PatchMapping`
- **Fix**: Doi thanh `patch()`

```dart
// Cu (sai):
await _api.put(ApiConstants.resolve(...));

// Moi (dung):
await _api.patch(ApiConstants.resolve(...));
```

#### 3. Danh sach nhan vien bi crash khi parse response

- **File**: `lib/core/di/management_providers.dart` — `staffMemberListProvider`
- **Loi**: Code cast truc tiep `json as List` nhung backend tra `PageResponse{content:[...], page:0, ...}`
- **Fix**: Dung helper `_items(json)` da co san (cung file) de xu ly ca hai truong hop

```dart
// Cu (crash):
fromData: (json) => (json as List).map(...).toList(),

// Moi (dung):
fromData: (json) => _items(json).map(...).toList(),
```

#### 4. quotationId null crash khi parse don hang

- **File**: `lib/data/models/response/order_response.dart` + `order_response.g.dart`
- **Loi**: `final int quotationId` non-nullable nhung server tra `null` khi don hang khong co bao gia
- **Fix**: Doi sang `final int? quotationId` (nullable)
- **Anh huong**: Cap nhat them 2 cho dung `.quotationId.toString()` sang `.quotationId?.toString() ?? ''`
  - `lib/data/repositories/order_repository_impl.dart`
  - `lib/core/di/staff_providers.dart`

#### 5. weightRange / cargoType null crash khi parse bao gia

- **File**: `lib/data/models/response/order_response.dart` + `order_response.g.dart`
- **Loi**: `final String weightRange` va `final String cargoType` non-nullable nhung DB khong co `NOT NULL`
- **Fix**: Doi ca hai sang nullable `String?`
- **Anh huong**: Cap nhat UI dung `?? 'N/A'` tai `quotation_approval_screen.dart`

#### 6. CORS backend thieu method PATCH

- **File**: `backend/src/main/java/com/quyenauto/config/CorsConfig.java`
- **Loi**: `allowedMethods` chi co `GET, POST, PUT, DELETE, OPTIONS` nhung backend co nhieu `@PatchMapping`
- **Fix**: Them `PATCH` vao danh sach

```java
// Cu:
config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));

// Moi:
config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
```

#### 7. Security: xoa FCM token cua nguoi khac

- **File**: `backend/.../notification/controller/NotificationController.java`
- **Loi**: `DELETE /notifications/fcm-token/{token}` khong kiem tra userId — ai cung co the xoa token cua nguoi khac
- **Fix**: Truyen `Authentication` vao controller, lay `userId`, goi service voi ca `userId` + `token`
- **Files thay doi**:
  - `NotificationController.java` — them `Authentication auth`, lay `userId`
  - `NotificationService.java` — doi `removeFcmToken(String)` thanh `removeFcmToken(Long userId, String)`
  - `FcmTokenRepository.java` — them method `deleteByUserIdAndToken(Long userId, String token)`

### Cac van de con lai (chua fix, khong anh huong runtime hien tai)

| Van de | File | Ghi chu |
|--------|------|---------|
| Race condition order code | `OrderService.java` | Dung `count+1`, co the trung khi 2 request cung luc |
| N+1 query DepartmentService | `DepartmentService.java` | Moi department goi 2 query rieng le |
| ChatController khong authorize | `ChatController.java` | Bat ky user nao co the tao phong chat giua 2 nguoi khac |
| DB password trong dev yml | `application-dev.yml` | Khong commit len public repo |
| 54 style hints | Nhieu file | `unnecessary_underscores`, `use_null_aware_elements` |
| `dealerNearest` endpoint khong ton tai | `DealerController.java` | Constant khai bao nhung chua implement backend |

---

## SESSION 3 — Kiem tra sau (2026-05-11)

Da kiem tra ky toan bo cac file Flutter + Spring Boot lan 2. Tim them cac loi nghiem trong.

### Cac loi nghiem trong da fix (commit c7cded1)

#### 1. OrderResponse.statusLogs null crash — crash khi load bat ky trang don hang

- **Nguyen nhan**: Flutter `order_response.dart` co `required this.statusLogs` non-nullable. Backend `OrderResponse.java` chua co truong `statusLogs` nen JSON tra ve khong co field nay. Generated code: `(json['statusLogs'] as List<dynamic>).map(...)` → `json['statusLogs']` la null → CRASH.
- **Fix Flutter**: Doi sang null-safe: `(json['statusLogs'] as List<dynamic>? ?? []).map(...)`
- **Fix Backend**: Them `statusLogs` vao `OrderResponse.java` (dung inner class `StatusLogDto`), map tu `o.getStatusLogs()`
- **Files**: `order_response.g.dart`, `OrderResponse.java`

#### 2. WarrantyRequestResponse.vehicle null crash — crash khi staff mo tab quan ly bao hanh

- **Nguyen nhan**: Backend `WarrantyResponse.java` tra ve flat fields (`vehicleId`, `plateNumber`, `chassisNumber`) thay vi nested object. Flutter `warranty_response.g.dart` lam: `VehicleResponse.fromJson(json['vehicle'] as Map)` → `json['vehicle']` la null → CRASH.
- **Fix Backend**: Cap nhat `WarrantyResponse.java` de tra ve nested `VehicleInfo` object (gom `id`, `plateNumber`, `chassisNumber`, `purchaseDate`)
- **Fix Flutter**: Doi `VehicleResponse` → `VehicleInfo` class (khong co `product` nested nua), `purchaseDate` doi thanh `String?`
- **Files**: `WarrantyResponse.java`, `warranty_response.dart`, `warranty_response.g.dart`

#### 3. WarrantyRequestResponse.logs null crash

- **Nguyen nhan**: Backend `WarrantyResponse.java` chua co truong `logs`. Flutter `warranty_response.g.dart` lam: `(json['logs'] as List<dynamic>).map(...)` → null CRASH.
- **Fix Backend**: Them `logs` vao `WarrantyResponse.java`, map tu `w.getLogs()`
- **Fix Flutter**: Doi sang null-safe: `(json['logs'] as List<dynamic>? ?? []).map(...)`
- **Files**: `WarrantyResponse.java`, `warranty_response.g.dart`

#### 4. GET /warranty/vehicles endpoint khong ton tai (404)

- **Nguyen nhan**: Flutter goi `GET /warranty/vehicles` de lay danh sach xe, nhung `WarrantyController.java` khong co endpoint nay.
- **Fix**: Them endpoint `GET /warranty/vehicles` vao controller, them `getMyVehicles(Long customerId)` vao service, tao `VehicleDetailResponse.java` DTO moi
- **Files**: `WarrantyController.java`, `WarrantyService.java`, `VehicleDetailResponse.java` (moi)

#### 5. Vehicle entity fields sai hoan toan

- **Nguyen nhan**: Flutter `Vehicle` entity co `truckType`, `warrantyExpiry`, `bodySerialNumber` nhung backend `Vehicle` entity khong co cac truong nay. `WarrantyRepositoryImpl._mapVehicle()` cast `v['id'] as String` trong khi backend tra so. → CRASH khi chay.
- **Fix**: Cap nhat Flutter `Vehicle` entity chi giu lai cac truong backend thuc su co (`id`, `plateNumber`, `chassisNumber`, `purchaseDate?`, `productName?`). Cap nhat `_mapVehicle()` de dung `(v['id'] as num).toString()`
- **Files**: `warranty.dart`, `warranty_repository_impl.dart`

### Cac man hinh hien dang "Coming Soon" — Chua co loi crash (chua implement)

| Man hinh | File | Ghi chu |
|----------|------|---------|
| Bao hanh khach hang | `warranty_screen.dart` | TODO stub |
| Danh sach xe | `vehicle_list_screen.dart` | TODO stub |
| Them xe | `add_vehicle_screen.dart` | TODO stub |
| Chat | `chat_screen.dart` | TODO stub — WebSocket da fix topic |

### Cac van de con lai sau session 3

| Van de | File | Ghi chu |
|--------|------|---------|
| Race condition order code | `OrderService.java` | `count+1`, co the trung khi 2 request cung luc |
| N+1 query DepartmentService | `DepartmentService.java` | Moi department goi 2 query rieng le |
| ChatController khong authorize | `ChatController.java` | Bat ky user login co the tao phong chat giua 2 nguoi khac |
| DB password trong dev yml | `application-dev.yml` | Khong commit len public repo |
| 54 style hints | Nhieu file | `info` level, khong anh huong runtime |
| `dealerNearest` 404 | `DealerController.java` | Constant khai bao nhung chua implement endpoint |
| `result` field warranty gui sai | `staff_providers.dart` dong 148 | `data: {'status': result, 'result': result}` — nen tach thanh 2 tham so rieng |

---

## SESSION 4 — Implement Coming Soon Features (2026-05-11)

Da implement tat ca cac man hinh "Coming Soon" co the lam va fix model chat sai.

### 1. Fix `ChatRoomResponse` model Flutter sai hoan toan (crash an)

- **Nguyen nhan**: Backend `ChatRoomResponse.java` tra ve `lastMessage: String` (ten noi dung), `lastMessageAt: LocalDateTime`, `unreadCount: Long`, `customerName`, `customerAvatar`. Flutter model lai co `lastMessage: MessageResponse?` (nested object). → CRASH khi JSON parse.
- **Fix Flutter**:
  - `lastMessage`: `MessageResponse?` → `String?`
  - Them `lastMessageAt: DateTime?`
  - Them `customerName: String?`, `customerAvatar: String?`
  - `MessageResponse`: Them `roomId`, `senderName`, `senderAvatar` (match `ChatMessageResponse.java`)
- **Files**: `chat_response.dart`, `chat_response.g.dart`

### 2. Fix `staff_chat_list_screen.dart` theo model moi

- Doi `lastMsg.content` → `room.lastMessage`
- Doi `lastMsg.createdAt` → `room.lastMessageAt`
- Hien thi avatar + ten khach hang thay vi avatar nhan vien (vi staff nhin thay khach hang)
- **File**: `staff_chat_list_screen.dart`

### 3. Tao `warranty_providers.dart` (moi)

- `myVehiclesProvider` — goi `warrantyRepository.getMyVehicles()` (GET /warranty/vehicles)
- `myWarrantyListProvider` — goi `GET /warranty` (phan trang, null-safe)
- `WarrantyActionsNotifier` + `warrantyActionsProvider` — tao yeu cau bao hanh
- **File**: `lib/core/di/warranty_providers.dart` (moi)

### 4. Tao `chat_providers.dart` (moi)

- `chatRoomsProvider` — GET /chat/rooms
- `chatHistoryProvider(roomId)` — GET /chat/rooms/{roomId}/messages (phan trang)
- `ChatRoomNotifier` + `chatRoomNotifierProvider(roomId)`:
  - Subscribe WebSocket `/topic/chat.room.{roomId}` khi khoi tao
  - `loadHistory()` — them lich su vao state, tranh trung lap theo id
  - `sendMessage()` — gui WS den `/app/chat.send` voi JSON `{roomId, content, type: TEXT}`
  - `markAsRead()` — goi REST POST /chat/rooms/{roomId}/read
- **File**: `lib/core/di/chat_providers.dart` (moi)

### 5. Them API constants moi

- `chatMarkRead = 'chat/rooms/{roomId}/read'`
- `chatInit = 'chat/rooms/init'`
- **File**: `api_constants.dart`

### 6. Implement `warranty_screen.dart` (Customer)

- Thay the stub "Coming Soon" bang man hinh day du:
  - Section "Xe cua toi" voi horizontal list card + nut "Xem tat ca"
  - Section "Lich su yeu cau bao hanh" voi list tile co status chip + logs summary
  - FAB "Yeu cau bao hanh" → dialog chon xe + nhap mo ta
  - Pull-to-refresh, empty states, error states
- **File**: `warranty_screen.dart`

### 7. Implement `vehicle_list_screen.dart` (Customer)

- Thay the stub bang man hinh danh sach xe day du
- Hien thi bien so, so khung, ten san pham, ngay mua
- Pull-to-refresh, empty state, error state
- **File**: `vehicle_list_screen.dart`

### 8. Implement `add_vehicle_screen.dart`

- Backend khong co endpoint `POST /warranty/vehicles` → xe duoc dang ky boi staff
- Man hinh nay giai thich quy trinh va cung cap nut "Goi Hotline" + "Chat Zalo"
- **File**: `add_vehicle_screen.dart`

### 9. Implement `chat_screen.dart` (Customer + Staff)

- Thay the stub bang man hinh chat day du:
  - Load lich su tin nhan REST khi vao man hinh
  - Subscribe WebSocket real-time nhan tin nhan moi
  - Bubble UI: tin nhan cua minh (phai, cam) vs nguoi kia (trai, trang)
  - Avatar + ten nguoi gui cho tin nhan cua nguoi khac
  - Icon trang thai da doc (done_all xanh / done xam)
  - DateDivider phan cach cac ngay
  - Input bar nhieu dong + nut gui
  - Tu dong scroll xuong tin moi nhat
  - Mark as read khi vao phong
- **File**: `chat_screen.dart`

### 10. Them `CustomerChatListScreen` (moi)

- Danh sach phong chat cua khach hang (gong nhu staff)
- Neu chi 1 phong → tu dong chuyen den ChatScreen
- **File**: `lib/presentation/chat/customer_chat_list_screen.dart` (moi)

### 11. Cap nhat routes

- Them `AppRoutes.chatList = '/chat-rooms'` → `CustomerChatListScreen`
- Them `AppRoutes.vehicleList = '/vehicles'` → `VehicleListScreen`
- **Files**: `route_paths.dart`, `app_router.dart`

### 12. Wire Profile → Chat

- "Ho tro khach hang" trong profile: `onTap: () {}` → `context.push(AppRoutes.chatList)`
- **File**: `profile_screen.dart`

### 13. Export providers moi

- `providers.dart` export them `warranty_providers.dart`, `chat_providers.dart`
- **File**: `providers.dart`

### Ket qua

- Flutter analyze: **0 errors, 0 warnings** (59 info style hints pre-existing)
- Tat ca 4 man hinh "Coming Soon" da duoc implement
- Chat model match voi backend hoan toan


---

## SESSION 5 — Implement Remaining Features (2026-05-11)

### 1. Implement Notification Screen

- Thay the stub "Coming Soon" bang man hinh thong bao day du
- Hien thi list voi icon theo type (ORDER/WARRANTY/QUOTATION/SYSTEM)
- Nut "Doc tat ca" xuat hien khi co tin chua doc (goi `POST /notifications/mark-read`)
- Tap vao thong bao → mark 1 tin doc + navigate (ORDER → order detail)
- Badge dot cam cho tin chua doc, nen xanh nhat cho hang chua doc
- Pull-to-refresh
- **File**: `notification_screen.dart`

### 2. Them `NotificationActionsNotifier` vao notification_providers

- `markAllRead()` — goi `POST /notifications/mark-read`
- `markOneRead(id)` — goi `POST /notifications/{id}/read`
- **File**: `notification_providers.dart`

### 3. Them updateProfile + changePassword vao AuthNotifier

- `updateProfile({fullName, email, avatarUrl})` — goi `PUT /auth/me`, sau do re-fetch profile
- `changePassword({currentPassword, newPassword})` — goi `POST /auth/change-password`
- **File**: `auth_providers.dart`

### 4. Implement "Thong tin ca nhan" trong Profile Screen (Customer)

- Bottom sheet voi TextField ho ten + email
- Goi `authProvider.notifier.updateProfile()`
- **File**: `profile_screen.dart`

### 5. Implement "Doi mat khau" trong Profile Screen (Customer)

- Bottom sheet voi 3 truong: mat khau hien tai, mat khau moi, xac nhan
- Nut hien/an mat khau (StatefulBuilder + bool state ben ngoai builder)
- Validate: khong de trong, mat khau moi >= 6 ky tu, xac nhan phai khop
- **File**: `profile_screen.dart`

### 6. Wire Staff Profile Screen Buttons

- "Thong tin ca nhan" → bottom sheet edit profile (fullName, email)
- "Doi mat khau" → bottom sheet doi mat khau
- "Cai dat thong bao" → navigate den `/staff/notifications` (NotificationScreen)
- "Tro giup" → bottom sheet Hotline + Email
- **File**: `staff_profile_screen.dart`

### 7. Them StaffRoutes.notifications + route

- `StaffRoutes.notifications = '/staff/notifications'`
- Dang ky trong `app_router.dart` → `NotificationScreen`
- **Files**: `route_paths.dart`, `app_router.dart`

### Ket qua

- Flutter analyze: **0 errors, 0 warnings** (64 info style hints)
- Tat ca chuc nang "Coming Soon" / onTap: () {} da duoc implement

---

## SESSION 6 — Backend endpoints con thieu + Fix remaining gaps (2026-05-11)

Da kiem tra lai toan bo frontend va backend, tim va implement tat ca cac endpoint con thieu.

### Backend — Endpoint moi them

#### 1. `POST /notifications/{id}/read` — Danh dau 1 thong bao da doc

- **Van de**: Flutter `notification_providers.dart` goi `POST /notifications/{id}/read` nhung backend khong co endpoint nay. Chi co `POST /notifications/mark-read` (danh dau TAT CA).
- **Fix**:
  - `NotificationRepository.java`: Them query `@Modifying` moi:
    ```java
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.id = :id AND n.user.id = :userId")
    void markOneReadByIdAndUserId(Long id, Long userId);
    ```
  - `NotificationService.java`: Them method `markOneRead(Long userId, Long notificationId)`
  - `NotificationController.java`: Them endpoint `@PostMapping("/{id}/read")`
- **Files**: `NotificationRepository.java`, `NotificationService.java`, `NotificationController.java`

#### 2. `GET /dealers/nearest` — Tim dai ly gan nhat theo GPS

- **Van de**: `ApiConstants.dealerNearest = 'dealers/nearest'` da khai bao trong Flutter nhung backend khong co endpoint. `DealerController` chi co `GET /dealers` va `GET /dealers/{id}`.
- **Fix**:
  - `DealerService.java`: Them `getNearest(double lat, double lng, int limit)` su dung cong thuc **Haversine** tinh khoang cach km, sap xep tang dan, lay `limit` ket qua dau tien.
  - `DealerController.java`: Them `@GetMapping("/dealers/nearest")` voi params `lat`, `lng`, `limit` (mac dinh 5).
  - Luu y: Spring MVC uu tien path literal truoc path variable, nen `/dealers/nearest` duoc match truoc `/dealers/{id}`.
- **Files**: `DealerService.java`, `DealerController.java`

#### 3. `PUT /auth/me` — Cap nhat thong tin ca nhan

- **Van de**: Flutter `auth_providers.dart` goi `PUT /auth/me` de cap nhat ho ten/email/avatar nhung `AuthController` chi co `GET /auth/me`, khong co `PUT`.
- **Fix**:
  - `UpdateProfileRequest.java` (moi): DTO voi 3 truong `fullName`, `email`, `avatarUrl` + validation `@Size`, `@Email`
  - `AuthService.java`: Them `updateProfile(Long userId, UpdateProfileRequest)`:
    - Kiem tra email trung truoc khi cap nhat
    - Email/avatarUrl blank → set null
  - `AuthController.java`: Them `@PutMapping("/me")`
- **Files**: `UpdateProfileRequest.java` (moi), `AuthService.java`, `AuthController.java`

#### 4. `POST /auth/change-password` — Doi mat khau

- **Van de**: Flutter goi `POST /auth/change-password` nhung backend khong co endpoint nay.
- **Fix**:
  - `ChangePasswordRequest.java` (moi): DTO voi `currentPassword`, `newPassword` + validation `@Size(min=6)`
  - `AuthService.java`: Them `changePassword(Long userId, ChangePasswordRequest)`:
    - Kiem tra mat khau hien tai bang `passwordEncoder.matches()`
    - Neu sai → throw `BusinessException(UNAUTHORIZED, "Mat khau hien tai khong dung")`
    - Neu dung → encode va luu mat khau moi
  - `AuthController.java`: Them `@PostMapping("/change-password")`
- **Files**: `ChangePasswordRequest.java` (moi), `AuthService.java`, `AuthController.java`

#### 5. `PATCH /orders/{id}/cancel` — Khach hang huy don hang

- **Van de**: `OrderDetailScreen` co nut "Huy don hang" nhung chi dong dialog, khong goi API. Backend khong co endpoint huy don phia khach hang, chi co `PATCH /staff/orders/{id}/status` cho staff.
- **Fix**:
  - `OrderService.java`: Them `cancelOrder(Long customerId, Long orderId)`:
    - Kiem tra khach hang so huu don: `order.getCustomer().getId().equals(customerId)` → 403 neu sai
    - Kiem tra trang thai PENDING: chi cho huy khi con PENDING → 400 neu khac
    - Them log "Khach hang huy don", set status CANCELLED
  - `OrderController.java`: Them `@PatchMapping("/orders/{id}/cancel")`
- **Files**: `OrderService.java`, `OrderController.java`

---

### Flutter — Fix va implement phan con lai

#### 6. Wire nut "Huy don" trong OrderDetailScreen

- **Van de**: Nut "Huy don hang" o `order_detail_screen.dart` chi goi `Navigator.pop(context)` khi bam "Huy don" trong dialog — khong goi API nao.
- **Fix**:
  - `api_constants.dart`: Them `cancelOrder = 'orders/{id}/cancel'`
  - `order_providers.dart`: Them `OrderActionsNotifier` voi method `cancelOrder(orderId)` goi `PATCH /orders/{id}/cancel`, sau do invalidate `orderListProvider` va `orderDetailProvider`
  - `order_detail_screen.dart`:
    - Them import `order_providers.dart`
    - Doi `_OrderDetailView` tu `StatelessWidget` → `ConsumerWidget` (can `WidgetRef ref` de goi provider)
    - `_confirmCancel()` nhan them tham so `WidgetRef ref`
    - Khi confirm: goi `ref.read(orderActionsProvider.notifier).cancelOrder(orderId)`, hien SnackBar, quay ve man hinh truoc
    - Bao loi duoc hien SnackBar mau do
- **Files**: `api_constants.dart`, `order_providers.dart`, `order_detail_screen.dart`

#### 7. Nut "Quen mat khau" trong LoginScreen

- **Van de**: Nut "Quen mat khau" co `onPressed: isLoading ? null : () {}` → bam khong lam gi.
- **Fix**: Them method `_showForgotPasswordDialog()` hien `AlertDialog` giai thich lien he tong dai, co nut "Goi tong dai" mo `tel:0908109929` qua `url_launcher`.
- **Files**: `login_screen.dart`

#### 8. Staff Profile — Them show/hide toggle cho o nhap mat khau

- **Van de**: Bottom sheet "Doi mat khau" cua staff (`_showChangePasswordSheet` trong `staff_profile_screen.dart`) su dung `obscureText: true` co dinh, khong co nut hien/an mat khau. Khac biet so voi man customer da co toggle.
- **Fix**: Boc bang `StatefulBuilder`, khai bao `bool showCurrent = false`, `bool showNew = false` ben ngoai `builder:` (de tranh reset khi setState). Them `IconButton` suffixIcon voi `Icons.visibility` / `Icons.visibility_off`.
- **File**: `staff_profile_screen.dart`

---

### Tong ket trang thai sau Session 6

#### Da implement day du (tat ca chuc nang co the lam)

| Chuc nang | Backend | Flutter |
|-----------|---------|---------|
| Xem san pham, chi tiet san pham | ✅ | ✅ |
| Yeu cau bao gia | ✅ | ✅ |
| Danh sach don hang + chi tiet | ✅ | ✅ |
| **Huy don hang (khach hang)** | ✅ vua them | ✅ vua fix |
| Chat realtime (WebSocket + REST) | ✅ | ✅ |
| Thong bao (danh dau 1/tat ca da doc) | ✅ vua them | ✅ |
| Bao hanh (xem xe, tao yeu cau) | ✅ | ✅ |
| Cap nhat thong tin ca nhan | ✅ vua them | ✅ |
| **Doi mat khau** | ✅ vua them | ✅ |
| **Quen mat khau** | N/A (hotline) | ✅ vua them |
| Staff: quan ly don hang | ✅ | ✅ |
| Staff: duyet bao gia | ✅ | ✅ |
| Staff: quan ly bao hanh | ✅ | ✅ |
| Staff: chat voi khach | ✅ | ✅ |
| Staff: ban do dai ly + GPS | ✅ vua them /nearest | ✅ |
| Staff: quan ly phong ban + nhan vien | ✅ | ✅ |
| **Staff profile: show/hide mat khau** | N/A | ✅ vua fix |

#### Con lai co chu y de lai (khong implement)

| Chuc nang | Ly do |
|-----------|-------|
| Dang nhap Zalo OAuth | Can tich hop Zalo SDK ben thu 3 + backend verify token that — phuc tap, ngoai pham vi hien tai |
| `chat_repository_impl.dart` (stub cu) | File cu con ton tai nhung khong duoc dung (logic that nam trong `chat_providers.dart`). Khong anh huong runtime. |

---

## Quy tac ghi note

> **Tu session 6 tro di**: Moi lan co thay doi (fix bug, them tinh nang, sua endpoint, ...) phai **cap nhat file nay ngay** voi SESSION moi o cuoi file. Khong de note bi tre.

---

## SESSION 7 — Production Hardening (2026-05-11)

### Bước 1: Tách secrets ra .env — xóa credential khỏi source code

**Vấn đề**: `application-dev.yml` chứa mật khẩu DB thật (`${DB_PASSWORD:159357bapD}`) và `application.yml` chứa JWT secret yếu dưới dạng default fallback — nếu deploy mà quên set env var thì dùng luôn secret yếu/rò rỉ mật khẩu.

**Fix**:

1. **`backend/src/main/resources/application-dev.yml`**
   - Thêm `spring.config.import: optional:file:./.env[.properties]` — Spring Boot tự đọc file `.env` tại thư mục chạy app
   - Đổi `${DB_PASSWORD:159357bapD}` → `${DB_PASSWORD}` (bỏ default nguy hiểm)

2. **`backend/src/main/resources/application.yml`**
   - Đổi `${JWT_SECRET:quyen-auto-default-jwt-secret-key-change-in-production-2024}` → `${JWT_SECRET}` (bắt buộc phải set)

3. **`backend/.env`** (MỚI — **gitignored** theo `backend/.gitignore: *.env`)
   - Chứa giá trị thật cho dev: `DB_PASSWORD`, `JWT_SECRET`, `MAIL_*`, `CLOUDINARY_*`
   - **Không commit file này**

4. **`backend/.env.example`** (MỚI — **được commit** làm template)
   - Hướng dẫn dev mới copy thành `.env` và điền giá trị

**Lệnh để chạy dev sau khi thay đổi**:
```bash
# Từ thư mục backend/
cp .env.example .env
# Điền DB_PASSWORD và JWT_SECRET thật vào .env
mvn spring-boot:run
```

**Kiểm tra**: `git check-ignore -v backend/.env` → matched bởi `backend/.gitignore:*.env` ✅

---

### Bước 2: Rate limiting cho POST /auth/login — chặn brute force

**Vấn đề**: `/auth/login` không có giới hạn số lần thử → attacker có thể brute-force mật khẩu.

**Fix**: Thêm `LoginRateLimitFilter` dùng Bucket4j in-memory:
- **5 attempts / IP / 15 phút**
- Trả về `429 Too Many Requests` + JSON message khi vượt giới hạn
- Đọc IP từ `X-Forwarded-For` (hỗ trợ reverse proxy), fallback về `getRemoteAddr()`

**Files thay đổi**:
- `backend/pom.xml` — thêm `com.github.bucket4j:bucket4j-core:8.10.1`
- `backend/src/main/java/com/quyenauto/config/LoginRateLimitFilter.java` — **MỚI**, `@Component @Order(1)`

**Phía Flutter**: Không cần sửa — `ApiService._extractServerMessage()` đã tự extract `message` từ JSON response, SnackBar sẽ hiển thị đúng.

**Response khi bị rate limit**:
```json
{
  "success": false,
  "message": "Qua nhieu lan dang nhap that bai. Vui long thu lai sau 15 phut.",
  "statusCode": 429
}
```

---

### Bước 3: Fix ChatController — kiểm tra quyền vào phòng chat

**Vấn đề**:
1. `GET /chat/rooms/{roomId}/messages` — không có `Authentication` param → **bất kỳ user đã đăng nhập nào** cũng đọc được tin nhắn của mọi phòng chat (kể cả phòng họ không phải thành viên).
2. `POST /chat/rooms/init?customerId=X&staffId=Y` — không kiểm tra caller → customer có thể tạo phòng chat "nhân danh" customer khác.

**Fix**:

**`ChatService.java`** — đổi signature `getMessages`, thêm membership check:
```java
public Page<ChatMessageResponse> getMessages(Long roomId, Long requesterId, Pageable pageable) {
    ChatRoom room = roomRepository.findById(roomId)
        .orElseThrow(() -> new BusinessException(NOT_FOUND, "Không tìm thấy phòng chat"));
    boolean isMember = room.getCustomer().getId().equals(requesterId)
        || (room.getStaff() != null && room.getStaff().getId().equals(requesterId));
    if (!isMember) throw new BusinessException(FORBIDDEN, "Bạn không có quyền...");
    return messageRepository.findByRoomIdOrderByCreatedAtDesc(roomId, pageable)...;
}
```

**`ChatController.java`**:
- `getMessages` — thêm `Authentication auth`, truyền `userId` vào service
- `getOrCreateRoom` — thêm `Authentication auth`; nếu caller có `ROLE_CUSTOMER` thì `customerId` phải bằng `callerId`, ngược lại (staff/manager/admin) cho phép tạo bất kỳ

**Không cần sửa Flutter** — các request từ app đều đúng (customer gửi `customerId` của chính họ).

---

### Bước 7: WebSocket auto-reconnect với exponential backoff

**Vấn đề**: `websocket_service.dart` cũ:
1. Dùng `reconnectDelay: Duration(seconds: 5)` của stomp — cố định 5s, không backoff
2. `onDisconnect` clear `_subscriptions` nhưng **không re-subscribe** sau khi kết nối lại → chat và order update ngừng hoạt động sau khi mất mạng rồi online lại

**Fix** — Rewrite `websocket_service.dart`:
- Tắt stomp auto-reconnect (`reconnectDelay: Duration(days: 1)`)
- Tự handle reconnect với exponential backoff: **2s → 4s → 8s → 16s → 32s → 60s (max)**
- Lưu `_subscriptionCallbacks` map; sau mỗi `onConnect` gọi `_resubscribeAll()` để restore tất cả topic đã subscribe
- `disconnect()` intentional không trigger reconnect

**Backoff formula**: `delay = 2 * 2^(attempt-1)`, capped ở 60s

---

### Bước 8: Fix race condition mã đơn hàng

**Vấn đề**: `generateOrderCode()` dùng `orderRepository.count() + 1` — nếu 2 request đồng thời, cả 2 có thể get cùng count → trùng mã đơn hàng (lỗi `UNIQUE constraint failed`).

**Fix**: Thay bằng UUID-based code:
```java
String prefix = "QA" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMM"));
String uniquePart = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
return prefix + uniquePart; // e.g. "QA2605A3F8B12C"
```
Format mới: `QA{yyMM}{8-hex}` = 14 chars, fit trong `length = 30`, zero collision probability.

**Lưu ý (Bước 8)**: `generateOrderCode()` hiện chưa được gọi ở đâu trong code — orders chưa có endpoint tạo mới. Fix này đảm bảo khi implement order creation sẽ an toàn.

---

### Bước 6: Cloudinary upload ảnh đại diện (avatar)

**Vấn đề**: Avatar profile chỉ hiển thị static, không thể thay đổi từ app.

**Backend**: Đã có sẵn `CloudinaryConfig`, `CloudinaryService`, `POST /upload` endpoint — chỉ cần wire Flutter.

**Flutter changes**:

1. **`pubspec.yaml`** — thêm `path: ^1.9.0` (để lấy `basename()` khi build multipart)

2. **`api_constants.dart`** — thêm `static const String upload = 'upload'`

3. **`api_service.dart`** — thêm `uploadFile(File file, {String folder})`:
   ```dart
   Future<String> uploadFile(File file, {String folder = 'general'}) async {
     final formData = FormData.fromMap({
       'file': await MultipartFile.fromFile(file.path, filename: basename(file.path)),
       'folder': folder,
     });
     // goi postMultipart, lay data String (URL)
   }
   ```

4. **`profile_screen.dart`** — convert `_ProfileHeader` từ `StatelessWidget` → `ConsumerStatefulWidget`:
   - Thêm camera badge overlay trên avatar
   - Tap avatar → `ImagePicker.pickImage()` → `api.uploadFile()` → `authProvider.updateProfile(avatarUrl: url)`
   - Show `CircularProgressIndicator` trong khi upload (`_uploading = true`)

**Flow**:
1. User tap avatar → gallery picker mở
2. Chọn ảnh → resize tối đa 512x512, quality 80%
3. Upload lên `POST /upload?folder=avatars`
4. Backend trả về URL Cloudinary
5. Gọi `PUT /auth/me` với `avatarUrl` mới
6. State refresh → avatar hiển thị ngay

**Lưu ý production**: Cần điền `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` vào `.env` (dev) hoặc env vars (prod).

---

### Bước 9: Workflow phê duyệt hủy đơn hàng

**Vấn đề trước**: Khách hàng cancel → đơn bị hủy ngay lập tức, không có bước xét duyệt của staff.

**Workflow mới**:
1. Khách hàng nhấn "Yêu cầu hủy đơn" → status: `CANCEL_REQUESTED`
2. Staff nhìn thấy badge "⚠️ Chờ duyệt hủy" → vào chi tiết để Approve/Reject
3. Approve → `CANCELLED` + OrderStatusLog
4. Reject → `PENDING` + OrderStatusLog

**Cho phép cancel từ**: `PENDING` hoặc `CONFIRMED` (trước chỉ `PENDING`)

**Backend changes**:
- `V2__add_cancel_requested_status.sql` — ALTER orders.status ENUM để thêm `CANCEL_REQUESTED`
- `Order.java` — thêm `CANCEL_REQUESTED` vào enum
- `OrderService.java` — `cancelOrder()` → `CANCEL_REQUESTED` thay vì `CANCELLED`; thêm `approveCancel()`, `rejectCancel()`
- `OrderController.java` — thêm `PATCH /staff/orders/{id}/cancel/approve` và `PATCH /staff/orders/{id}/cancel/reject`
- `api_constants.dart` — thêm `staffApproveCancel`, `staffRejectCancel`

**Flutter changes**:
- `order.dart` — thêm `cancelRequested` vào `OrderStatus` enum
- `app_colors.dart` — thêm màu cho `cancelrequested` (amber/warning)
- `order_detail_screen.dart` (customer) — nút "Yêu cầu hủy đơn", banner chờ duyệt khi status = cancelRequested
- `order_detail_staff_screen.dart` — thêm section Approve/Reject, handle case trong status switch
- `order_management_screen.dart` — thêm filter "Chờ duyệt hủy", thêm chip màu amber
- `order_providers.dart` — thêm `approveCancel()`, `rejectCancel()` vào `OrderActionsNotifier`
- `staff_providers.dart` — thêm `approveCancel()`, `rejectCancel()` vào `StaffActionsNotifier`

---

### Bước 5: FCM Push Notification — gửi thực sự khi có thông báo mới

**Mục tiêu**: Khi backend gọi `NotificationService.createNotification()`, server tự động gửi FCM push notification đến thiết bị của user. App đăng ký FCM token ngay sau khi đăng nhập thành công.

**Thiết kế graceful degradation**:
- Nếu `FIREBASE_SERVICE_ACCOUNT_JSON` chưa được set → app vẫn khởi động bình thường, push notification bị bỏ qua (log WARN)
- Nếu `google-services.json` chưa có trong Flutter → app vẫn build và chạy, FCM bị tắt tự động (try-catch)

**Backend changes**:

1. **`FcmConfig.java`** (MỚI, `config/`)
   - `@Bean FirebaseApp firebaseApp()` — đọc `${firebase.service-account-json:}` từ env
   - Nếu rỗng → log WARN + return `null` (bean null, app không crash)
   - Nếu có → parse JSON credentials, khởi tạo `FirebaseApp`
   - Check `!FirebaseApp.getApps().isEmpty()` tránh init lại khi dev hot-reload

2. **`FcmPushService.java`** (MỚI, `notification/service/`)
   - `@Service`, constructor `@Autowired @Nullable FirebaseApp` → null-safe khi Firebase chưa cấu hình
   - `send(List<String> tokens, String title, String body)`:
     - Bỏ qua nếu `firebaseApp == null` hoặc `tokens` rỗng
     - Chia batch <= 500 tokens (giới hạn FCM multicast)
     - Dùng `FirebaseMessaging.getInstance(app).sendEachForMulticast(MulticastMessage)`
     - Log success/failure count, log token thất bại ở DEBUG level

3. **`NotificationService.java`** — thêm `FcmPushService fcmPushService` (via `@RequiredArgsConstructor`):
   - Trong `createNotification()`: sau khi `notificationRepository.save()`, query tất cả FCM token của user → gọi `fcmPushService.send(tokens, title, body)`

4. **`application-dev.yml`** — thêm `firebase.service-account-json: ${FIREBASE_SERVICE_ACCOUNT_JSON:}`

5. **`backend/.env`** — thêm `FIREBASE_SERVICE_ACCOUNT_JSON=` (rỗng, để dev tắt FCM)

6. **`backend/.env.example`** — thêm hướng dẫn lấy service account JSON từ Firebase Console

**pom.xml** (đã thêm session trước):
- `firebase-admin:9.4.3`

**Flutter changes**:

7. **`main.dart`** và **`main_staff.dart`** — thêm Firebase init sau `dotenv.load()`:
   ```dart
   try {
     await Firebase.initializeApp();
   } catch (_) {
     // Firebase chua duoc cau hinh — FCM se bi vo hieu hoa
   }
   ```

8. **`auth_providers.dart`** — thêm `_registerFcmToken()`:
   ```dart
   Future<void> _registerFcmToken() async {
     try {
       await FirebaseMessaging.instance.requestPermission(...);
       final token = await FirebaseMessaging.instance.getToken();
       if (token == null) return;
       await api.post('notifications/fcm-token', data: {'token': token, 'deviceType': 'MOBILE'});
     } catch (_) {}
   }
   ```
   - Gọi `_registerFcmToken()` trong: `build()` (restore session), `login()`, `register()`, `loginWithZalo()`

**pubspec.yaml** (đã có sẵn từ trước): `firebase_core: ^3.8.0`, `firebase_messaging: ^15.1.5`

---

### Bước 4: OTP xác minh email sau đăng ký

**Vấn đề**: Không có cơ chế xác minh email → bất kỳ ai có thể đăng ký bằng email của người khác mà không cần xác nhận.

**Thiết kế (graceful, không breaking)**:
- Đăng ký có email → `emailVerified = false`, gửi OTP 6 chữ số qua email
- Đăng ký không có email → `emailVerified = true` (không cần xác minh)
- User có thể bỏ qua OTP → vẫn dùng được app, chỉ thấy banner nhắc trong profile
- User cũ (trước migration) → mặc định `emailVerified = TRUE`, không ảnh hưởng

**Bug Flyway đã fix**: Session trước tạo nhầm `V2__add_cancel_requested_status.sql` trong khi đã có `V2__fix_admin_password.sql`. Đã rename thành `V3__add_cancel_requested_status.sql`. OTP migration = `V4__otp_email_verification.sql`.

**Backend** (10 files):
- `V4__otp_email_verification.sql` — `ALTER TABLE users ADD email_verified`, `CREATE TABLE otp_codes`
- `User.java` — thêm `emailVerified = true`
- `OtpCode.java` (MỚI) — entity: `user_id, code, purpose, attempts, expires_at`
- `OtpCodeRepository.java` (MỚI) — `findLatestByUserIdAndPurpose()`, `deleteByUserIdAndPurpose()`
- `EmailService.java` (MỚI) — gửi email OTP; nếu MAIL_USERNAME rỗng → log ra console (dev mode)
- `OtpService.java` (MỚI) — `sendEmailVerificationOtp()` (SecureRandom 6 chữ số, expire 5 phút), `verifyEmailOtp()` (max 5 attempts)
- `AuthService.java` — inject OtpService; `register()` tự gửi OTP nếu có email (try-catch, không block đăng ký)
- `AuthResponse.UserInfo` — thêm `emailVerified`
- `VerifyOtpRequest.java` (MỚI) — DTO `code` (6 chars)
- `AuthController.java` — thêm `POST /auth/otp/send` và `POST /auth/otp/verify`

**Flutter** (7 files):
- `user.dart` — thêm `emailVerified` (default `true`)
- `auth_repository_impl.dart` — map `emailVerified` từ JSON
- `auth_providers.dart` — thêm `resendOtp()`, `verifyOtp(code)`
- `route_paths.dart` — thêm `verifyOtp = '/verify-otp'`
- `app_router.dart` — thêm route + cho phép `/verify-otp` trong onAuthScreen
- `OtpVerificationScreen` (MỚI) — 6 ô nhập số, countdown 5 phút, gửi lại, tự verify khi đủ 6 chữ
- `register_screen.dart` — sau register: `!emailVerified && email != null` → `/verify-otp`
- `profile_screen.dart` — `_EmailVerifyBanner` (amber) tap → `/verify-otp`

**Dev workflow**: OTP sẽ in ra Spring Boot console log khi chưa cấu hình mail. Grep log `OTP for`:
```
WARN OTP for user@example.com is: 482931
```

---

**Để bật FCM trong production**:
1. Tạo project Firebase tại console.firebase.google.com
2. Android: download `google-services.json` vào `android/app/`
3. iOS: download `GoogleService-Info.plist` vào `ios/Runner/`
4. Chạy `flutterfire configure` để tạo `lib/firebase_options.dart`
5. Sửa `main.dart` + `main_staff.dart`: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
6. Backend: lấy service account JSON (Firebase Console → Project Settings → Service Accounts → Generate new private key), điền vào `FIREBASE_SERVICE_ACCOUNT_JSON` trong `.env` (1 dòng, no line breaks)

---

## SESSION 8 — Cập nhật Logo & Gộp Worktrees (2026-05-15)

### 1. Cập nhật Logo Quyen Auto

**Vấn đề**: Toàn bộ app đang dùng placeholder icon xe tải cam thay vì logo thật của Quyen Auto.

#### 1.1 Logo trong Login Screen

- **File**: `lib/presentation/auth/login_screen.dart`
- **Thay đổi**: Thay `Container` với `Icons.local_shipping` màu cam → `Image.asset('assets/images/LOGO QA.png')`
- **Xóa**: Dòng chữ "Quyen Auto" và "Dang nhap de tiep tuc" bên dưới logo (logo đã có chữ sẵn)
- **Kích thước hiển thị**: width 200, height 120, fit: BoxFit.contain

#### 1.2 Logo trong Home AppBar

- **File**: `lib/presentation/home/home_screen.dart`
- **Thay đổi**: Thay `Container` vòng tròn cam + `Icons.local_shipping` + Text "Quyen Auto" → `Image.asset('assets/images/LOGO QA-white-red.png', height: 32)`
- **Lý do dùng `LOGO QA-white-red.png`**: Logo có nền trong suốt với màu trắng/đỏ — hiển thị tốt trên nền AppBar navy xanh (`#1A2A4A`)

#### 1.3 Launcher Icon (logo ngoài màn hình chính)

- **Thêm package**: `flutter_launcher_icons: ^0.14.3` vào `dev_dependencies`
- **Tạo file**: `flutter_launcher_icons.yaml`
- **Tạo file**: `assets/images/launcher_icon.png` — ảnh vuông 1024×1024, nền đen (`#000000`), logo trắng/đỏ căn giữa chiếm 75% chiều rộng
- **Script tạo**: Python + Pillow

```python
from PIL import Image
logo = Image.open("assets/images/LOGO QA-white-red.png").convert("RGBA")
canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 255))
new_w = int(1024 * 0.75)
new_h = int(new_w * logo.size[1] / logo.size[0])
logo_resized = logo.resize((new_w, new_h), Image.LANCZOS)
canvas.paste(logo_resized, ((1024 - new_w)//2, (1024 - new_h)//2), logo_resized)
canvas.save("assets/images/launcher_icon.png", "PNG")
```

- **Lệnh generate**: `dart run flutter_launcher_icons`
- **Kết quả**: Tự động tạo icon cho Android (mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi + adaptive v26), iOS (20×20 → 1024×1024), Web (favicon + PWA icons)

**Lưu ý launcher icon**: Android cache icon cũ — cần **uninstall app rồi install lại** để thấy icon mới trên màn hình chính.

---

### 2. Gộp Claude Worktrees vào main

Gộp toàn bộ 3 worktree vào nhánh `feature/test`:

#### 2.1 `claude/quizzical-rosalind-7e0d63` → commit `04a0cf4`

**Flutter**:
- `quotation_form_screen.dart` — mở rộng form báo giá (guest quotation, thêm trường)
- `quotation_approval_screen.dart` — UI nâng cấp: customer info, vehicle specs, dual-action buttons (đánh dấu đã liên hệ + gửi báo giá)
- `dashboard_screen.dart` — cập nhật dashboard staff
- `create_customer_screen.dart` (MỚI) — staff tạo tài khoản khách hàng trực tiếp
- `order_response.dart` + `order_response.g.dart` — thêm `productName`, `weightRange`/`cargoType` non-nullable
- `order_repository_impl.dart` — prefix `#QUO-` cho mã báo giá
- `websocket_service.dart` — thêm `subscribeStaffQuotations()`

**Backend**:
- `SecurityConfig.java` — cập nhật phân quyền
- `QuotationController.java` — thêm endpoint tạo báo giá cho khách vãng lai
- `QuotationService.java` — thêm `getPendingUncontacted()`, `countPendingUncontacted()`
- `UserController.java`, `UserService.java`, `UserRepository.java` — hỗ trợ tạo khách hàng bởi staff
- `GuestQuotationRequest.java` (MỚI) — DTO báo giá vãng lai
- `CreateCustomerRequest.java` (MỚI) — DTO tạo khách hàng
- `V2__quotation_extended_fields.sql` (MỚI) — migration thêm trường báo giá
- `V3__quotation_guest_and_customer_flow.sql` (MỚI) — migration flow khách vãng lai

#### 2.2 `feature/security-payment-chat` → commit `7cbf2aa`

**Flutter**:
- `chat_screen.dart` — viết lại hoàn chỉnh với state management, realtime subscription, error handling
- `app_router.dart` — thêm route `payment`
- `api_constants.dart` — thêm `paymentCreate`, `paymentCallback`

**Backend**:
- `AuthService.java` — thêm `LoginAttemptService` (chống brute force)
- `application.yml` — JWT expire rút xuống 1h, cấu hình SSL
- `.env.example` — thêm Redis, VNPay, SSL env vars

---

### 3. Fix lỗi compile sau merge (commit `adc7ea5`)

Sau khi gộp, merge conflict resolution làm mất một số route và import. Đã fix:

#### Routes bị thiếu trong `AppRoutes` (`app_router.dart`)

| Route | Hằng số thêm | Screen |
|-------|-------------|--------|
| `/register` | `AppRoutes.register` | `RegisterScreen` |
| `/verify-otp` | `AppRoutes.verifyOtp` | redirect → `/home` (OTP screen đã có riêng) |
| `/chat-list` | `AppRoutes.chatList` | `CustomerChatListScreen` |
| `/vehicle-list` | `AppRoutes.vehicleList` | `VehicleListScreen` |

#### Route bị thiếu trong `StaffRoutes` (`staff_router.dart`)

- Thêm `StaffRoutes.notifications = '/staff/notifications'` → `NotificationScreen`

#### Import bị thiếu

| File | Import thiếu |
|------|-------------|
| `login_screen.dart` | `app_flavor.dart`, `staff_router.dart` |
| `otp_verification_screen.dart` | `staff_router.dart` |

#### Kết quả sau fix

```
flutter analyze → 0 errors, 0 warnings (75 info style hints)
```

---

### Tổng kết tình trạng sau Session 8

| Hạng mục | Trạng thái |
|----------|-----------|
| Logo login screen | ✅ LOGO QA.png, không còn placeholder |
| Logo home AppBar | ✅ LOGO QA-white-red.png trên nền navy |
| Launcher icon Android | ✅ Đen + logo trắng/đỏ, tất cả density |
| Launcher icon iOS | ✅ 20×20 → 1024×1024 |
| Launcher icon Web | ✅ Favicon + PWA icons |
| Quotation flow mở rộng | ✅ Guest quotation, form mới |
| Staff tạo khách hàng | ✅ `CreateCustomerScreen` |
| VNPay payment | ✅ Routes + constants sẵn sàng |
| Chat cải thiện | ✅ Viết lại với state management đầy đủ |
| flutter analyze | ✅ 0 errors |

### Lệnh chạy app

```powershell
# Backend
cd "C:\Users\Admin\StudioProjects\quyen_auto_app\backend"
.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=dev

# Flutter (sau khi backend lên port 8080)
cd "C:\Users\Admin\StudioProjects\quyen_auto_app"
flutter run
```


