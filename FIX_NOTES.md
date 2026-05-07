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
