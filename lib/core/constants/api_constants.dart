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
  static const String myOrders        = 'orders/my';
  static const String orderDetail     = 'orders/{id}';
  static const String createQuotation = 'quotations';
  static const String myQuotations    = 'quotations';
  static const String updateStatus    = 'orders/{id}/status';

  // ─── Warranty ──────────────────────────────────────────────────────────────
  static const String vehicles         = 'warranty/vehicles';
  static const String warrantyRequests = 'warranty/requests';

  // ─── Chat ──────────────────────────────────────────────────────────────────
  static const String chatRooms    = 'chat/rooms';
  static const String chatMessages = 'chat/rooms/{roomId}/messages';

  // ─── Notifications ─────────────────────────────────────────────────────────
  static const String notificationList     = 'notifications';
  static const String notificationMarkRead = 'notifications/{id}/read';
  static const String fcmToken             = 'notifications/fcm-token';

  // ─── Dealers ───────────────────────────────────────────────────────────────
  static const String dealerList    = 'dealers';
  static const String dealerNearest = 'dealers/nearest';

  // ─── Staff: Orders ─────────────────────────────────────────────────────────
  static const String staffOrders       = 'staff/orders';
  static const String staffOrderDetail  = 'staff/orders/{id}';
  static const String staffUpdateStatus = 'staff/orders/{id}/status';

  // ─── Staff: Quotations ────────────────────────────────────────────────────
  static const String staffQuotations        = 'staff/quotations';
  static const String staffApproveQuote      = 'staff/quotations/{id}/approve';
  static const String staffQuotationContact  = 'staff/quotations/{id}/contact';

  // ─── Staff: Warranty ──────────────────────────────────────────────────────
  static const String staffWarrantyList   = 'staff/warranty';
  static const String staffWarrantyUpdate = 'staff/warranty/{id}';
  static const String staffWarrantyAssign = 'staff/warranty/{id}/assign';

  // ─── Staff: Dashboard ─────────────────────────────────────────────────────
  static const String staffDashboard = 'staff/dashboard';

  // ─── Departments ────────────────────────────────────────────────────────────
  static const String departments       = 'departments';
  static const String departmentDetail  = 'departments/{id}';

  // ─── Staff Management (admin/manager) ─────────────────────────────────────
  static const String staffMembers       = 'admin/staff';
  static const String staffMemberDetail  = 'admin/staff/{id}';
  static const String staffMemberCreate  = 'admin/staff';
  static const String staffMemberUpdate  = 'admin/staff/{id}';
  static const String staffMemberToggle  = 'admin/staff/{id}/toggle-active';

  // ─── Profile Update ────────────────────────────────────────────────────────
  static const String updateProfile     = 'auth/me';
  static const String changePassword    = 'auth/change-password';

  // ─── Admin: Products ──────────────────────────────────────────────────────
  static const String adminProducts      = 'admin/products';
  static const String adminProductDetail = 'admin/products/{id}';

  // ─── Staff: Customer Management ──────────────────────────────────────────
  static const String staffCustomers       = 'staff/customers';
  static const String staffCustomerDetail  = 'staff/customers/{id}';
  static const String staffCustomerToggle  = 'staff/customers/{id}/toggle-active';

  // ─── Leads (guest contact requests) ───────────────────────────────────────
  static const String guestLead  = 'leads';
  static const String staffLeads = 'leads';

  // ─── Reports ───────────────────────────────────────────────────────────────
  static const String reportDashboard = 'reports/dashboard';

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
