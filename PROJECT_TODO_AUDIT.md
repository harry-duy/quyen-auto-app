# Quyen Auto App - Nhung phan chua lam / can tiep tuc

File nay ghi lai cac phan con thieu sau khi quet project. Muc dich la de nguoi khac tiep tuc lam co the nam nhanh viec nao can xu ly truoc.

## 1. Man Bao hanh khach hang chua lam

Nhung file hien dang la placeholder / Coming Soon:

- `lib/presentation/warranty/warranty_screen.dart`
- `lib/presentation/warranty/add_vehicle_screen.dart`
- `lib/presentation/warranty/vehicle_list_screen.dart`

Tinh trang hien tai:

- Tab `Bao hanh` da co trong bottom navigation.
- Route `AddVehicleScreen` da co.
- Repository warranty da co mot phan.
- Backend da co API warranty.
- UI khach hang de xem xe, them xe, tao yeu cau bao hanh van chua hoan thien.

Can lam tiep:

- Man danh sach xe cua khach hang.
- Form them xe.
- Man danh sach yeu cau bao hanh.
- Form tao yeu cau bao hanh.
- Man chi tiet yeu cau bao hanh.
- Noi dung UI voi API backend that.

## 2. Man Thong bao chua lam

File hien dang la placeholder:

- `lib/presentation/notification/notification_screen.dart`

Tinh trang hien tai:

- App da co route `/notifications`.
- Home co nut chuong thong bao.
- Provider `notificationListProvider` da co.
- Backend co API `/notifications`.
- UI hien danh sach thong bao chua lam.

Can lam tiep:

- Hien danh sach thong bao.
- Hien trang thai da doc/chua doc.
- Xu ly empty state.
- Xu ly loading/error.
- Nut danh dau da doc.

Ghi chu:

- Endpoint mark-read da duoc sua trong `ApiConstants` thanh `notifications/mark-read`.
- Viec con lai la lam UI va action goi API.

## 3. Chat chua hoan thien

File hien dang la placeholder:

- `lib/presentation/chat/chat_screen.dart`

File repository con TODO:

- `lib/data/repositories/chat_repository_impl.dart`

Tinh trang hien tai:

- Backend co REST API chat:
  - `GET /chat/rooms`
  - `GET /chat/rooms/{roomId}/messages`
  - `POST /chat/rooms/{roomId}/read`
  - `POST /chat/rooms/init`
- Backend co WebSocket/STOMP.
- WebSocket endpoint `/ws` da duoc sua de phu hop Flutter raw WebSocket.
- Flutter co `WebSocketService`.
- UI chat van dang `Coming Soon`.

Can lam tiep:

- Man danh sach phong chat.
- Man chat hien lich su tin nhan.
- Gui tin nhan qua STOMP.
- Nhan tin nhan realtime.
- Danh dau da doc.
- Xu ly reconnect/offline.

## 4. Dang nhap bang Zalo chua lam

Tinh trang hien tai:

- Nut `Dang nhap bang Zalo` trong login screen chi show thong bao Coming Soon.
- Flutter co ham `loginWithZalo`.
- `ApiConstants` co `auth/zalo`.
- Backend hien chua thay endpoint `/auth/zalo`.

Can lam tiep:

- Tao OAuth flow Zalo tren Flutter.
- Cau hinh `ZALO_APP_ID` that.
- Them backend endpoint `/auth/zalo`.
- Backend verify code/token voi Zalo.
- Tao/lien ket user theo Zalo account.
- Test login role sau khi login Zalo.

## 5. ApiConstants / API client da sua mot phan, can test tiep tren app

Phan nay da duoc xu ly mot phan lon trong code Flutter. Khong dung den database.

Da sua endpoint:

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

Da sua them:

- Them `PATCH` vao `ApiService`.
- Doi staff actions sang dung `PATCH` voi nhung endpoint backend dang dung `@PatchMapping`.
- Sua mapper danh sach phan trang `PageResponse.content`.
- Sua payload duyet bao gia:
  - `quotedPrice`
  - `staffNote`
- Sua payload phan cong bao hanh:
  - `technicianId`
- Sua payload tao bao hanh:
  - `issueDescription`
- Sua tao bao gia parse `QuotationResponse`.

Tinh trang kiem tra:

- `flutter test` da pass `45/45`.
- `flutter analyze` khong co loi compile, chi con lint info cu.

Can lam tiep:

- Test truc tiep tren app voi backend dang chay:
  - order list
  - tao bao gia
  - staff order list
  - staff quotation list
  - staff warranty list
  - notification list sau khi lam UI
  - department/staff management
- Kiem tra lai `warranty/vehicles`: backend hien tai chua thay controller vehicle rieng. Neu app can danh sach xe that, can lam API/backend hoac dieu chinh lai luong bao hanh.

## 6. Profile chua hoan thien

Tinh trang hien tai:

- Profile co UI co ban.
- Nut `Thong tin ca nhan` chua co action.
- Nut `Doi mat khau` chua co man.
- Nut `Ho tro khach hang` chua mo chat that.

Backend co API lien quan:

```text
PUT  /auth/me
POST /auth/change-password
```

Can lam tiep:

- Man cap nhat thong tin ca nhan.
- Man doi mat khau.
- Validate form.
- Goi API update profile/change password.
- Refresh user profile sau khi cap nhat.

## 7. Cau hinh production chua san sang

File `.env` hien dang phu hop emulator Android:

```env
BASE_URL=http://10.0.2.2:8080/api/v1/
WS_URL=ws://10.0.2.2:8080/api/v1/ws
GOOGLE_MAPS_KEY=your_key_here
ZALO_APP_ID=your_zalo_app_id
```

Luu y:

- `10.0.2.2` chi dung cho Android emulator.
- Chay tren dien thoai that phai doi sang IP LAN/server that.
- `GOOGLE_MAPS_KEY` chua co key that.
- `ZALO_APP_ID` chua co app id that.

Backend dev config con default:

```text
DB_PASSWORD=QuyenAuto123
JWT_SECRET co default dev
CLOUDINARY_API_KEY rong
CLOUDINARY_API_SECRET rong
MAIL_USERNAME rong
MAIL_PASSWORD rong
```

Can lam tiep truoc khi deploy:

- Tach `.env.dev`, `.env.prod` hoac co cach build theo environment.
- Khong commit secret that.
- Cau hinh domain/IP backend that.
- Cau hinh JWT secret that.
- Cau hinh Cloudinary neu upload anh.
- Cau hinh mail neu can gui email.
- Cau hinh Firebase/FCM neu dung push notification.

## 8. Test con thieu

Tinh trang hien tai:

- Co mot so unit test repository.
- `test/widget_test.dart` chi la smoke placeholder.
- `flutter analyze` khong co loi compile, chi co lint info.
- `flutter test` hien tai pass `45/45`.

Can lam tiep:

- Test login customer/staff/admin routing.
- Test auth response mapping da co mot phan, co the bo sung route-level test.
- Test quotation flow.
- Test warranty flow sau khi lam UI.
- Test notification provider/screen.
- Test chat repository/websocket logic.
- Test backend integration neu co moi truong database test on dinh.

## 9. File nen don dep truoc khi ban giao/commit

Dang thay mot so file/folder untracked:

```text
.vscode/
FIX_NOTES.md
PROJECT_TODO_AUDIT.md
assets/
backend/login.json
backend/src/main/resources/db/migration/V2__fix_admin_password.sql
lib/core/router/route_paths.dart
```

Can quyet dinh:

- Commit `FIX_NOTES.md` neu muon luu note da fix.
- Commit `PROJECT_TODO_AUDIT.md` neu muon luu checklist viec can lam.
- Commit `assets/.gitkeep` neu can giu folder asset.
- Commit `V2__fix_admin_password.sql` neu database can migration nay.
- Commit `route_paths.dart` neu route moi dang duoc app dung.
- Xoa hoac khong commit `backend/login.json` vi chua tai khoan test.
- Kiem tra `.vscode/` co can commit khong.

## 10. Uu tien lam tiep

Thu tu nen lam:

1. Test truc tiep cac luong API vua sua tren emulator/app.
2. Lam man Bao hanh khach hang.
3. Lam man Thong bao.
4. Lam Chat that.
5. Lam Profile update va doi mat khau.
6. Xu ly Zalo login neu project that su can.
7. Tach cau hinh emulator / dien thoai that / production.
8. Bo sung test cho cac flow chinh.
