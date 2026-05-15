import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Tất cả endpoint của Quyen Auto API.
/// Base URL và WS URL đọc từ file .env — không hardcode trong source.
abstract final class ApiConstants {
  // ─── Base ──────────────────────────────────────────────────────────────────
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080/api/v1/';
  static String get wsUrl   => dotenv.env['WS_URL']   ?? 'ws://10.0.2.2:8080/ws';

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const String login    = 'auth/login';
  static const String register = 'auth/register';
  static const String refresh  = 'auth/refresh';
  static const String logout   = 'auth/logout';
  static const String zaloAuth = 'auth/zalo';
  static const String profile  = 'auth/me';

  // ─── Products ──────────────────────────────────────────────────────────────
  static const String productList   = 'products';
  static const String productDetail = 'products/{id}';

  // ─── Orders ────────────────────────────────────────────────────────────────
  static const String myOrders        = 'orders';
  static const String orderDetail     = 'orders/{id}';
  static const String cancelOrder          = 'orders/{id}/cancel';
  static const String createQuotation      = 'quotations';
  static const String createGuestQuotation = 'quotations/guest';
  static const String updateStatus    = 'orders/{id}/status';

  // ─── Warranty ──────────────────────────────────────────────────────────────
  static const String vehicles         = 'warranty/vehicles';
  static const String warrantyRequests = 'warranty';

  // ─── Chat ──────────────────────────────────────────────────────────────────
  static const String chatRooms      = 'chat/rooms';
  static const String chatMessages   = 'chat/rooms/{roomId}/messages';
  static const String chatMarkRead   = 'chat/rooms/{roomId}/read';
  static const String chatInit       = 'chat/rooms/init';

  // ─── Notifications ─────────────────────────────────────────────────────────
  static const String notificationList     = 'notifications';
  static const String notificationMarkRead = 'notifications/mark-read';
  static const String fcmToken             = 'notifications/fcm-token';

  // ─── Dealers ───────────────────────────────────────────────────────────────
  static const String dealerList    = 'dealers';
  static const String dealerNearest = 'dealers/nearest';

  // ─── Staff: Orders ─────────────────────────────────────────────────────────
  static const String staffOrders          = 'staff/orders';
  static const String staffOrderDetail     = 'staff/orders/{id}';
  static const String staffUpdateStatus    = 'staff/orders/{id}/status';
  static const String staffApproveCancel   = 'staff/orders/{id}/cancel/approve';
  static const String staffRejectCancel    = 'staff/orders/{id}/cancel/reject';

  // ─── Staff: Quotations ────────────────────────────────────────────────────
  static const String staffQuotations        = 'staff/quotations';
  static const String staffApproveQuote      = 'staff/quotations/{id}/approve';
  static const String staffMarkContacted     = 'staff/quotations/{id}/contacted';
  static const String staffPendingQuoteCount = 'staff/quotations/pending-count';

  // ─── Staff: Customer Management ─────────────────────────────────────────
  static const String staffCreateCustomer = 'staff/customers';

  // ─── Staff: Warranty ──────────────────────────────────────────────────────
  static const String staffWarrantyList   = 'staff/warranty';
  static const String staffWarrantyUpdate = 'staff/warranty/{id}/result';
  static const String staffWarrantyAssign = 'staff/warranty/{id}/assign';

  // ─── Staff: Dashboard ─────────────────────────────────────────────────────
  static const String staffDashboard = 'staff/dashboard';

  // ─── Departments ────────────────────────────────────────────────────────────
  static const String departments       = 'admin/departments';
  static const String departmentDetail  = 'admin/departments/{id}';

  // ─── Staff Management (admin/manager) ─────────────────────────────────────
  static const String staffMembers       = 'admin/staff';
  static const String staffMemberDetail  = 'admin/staff/{id}';
  static const String staffMemberCreate  = 'admin/staff';
  static const String staffMemberUpdate  = 'admin/staff/{id}';
  static const String staffMemberToggle  = 'admin/staff/{id}/toggle-active';

  // ─── Profile Update ────────────────────────────────────────────────────────
  static const String updateProfile     = 'auth/me';
  static const String changePassword    = 'auth/change-password';

  // ─── Upload ────────────────────────────────────────────────────────────────
  static const String upload            = 'upload';

  // ─── Reports ───────────────────────────────────────────────────────────────
  static const String reportDashboard = 'staff/dashboard';

  // ─── Helper: build URL có path param ──────────────────────────────────────
  /// Ví dụ: ApiConstants.resolve(orderDetail, {'id': '123'}) → 'orders/123'
  static String resolve(String endpoint, Map<String, String> params) {
    var result = endpoint;
    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}
