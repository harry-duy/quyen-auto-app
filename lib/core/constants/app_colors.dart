import 'package:flutter/material.dart';

/// Bảng màu chính thức của Quyen Auto Mobile System.
/// Mọi màu sắc trong app phải tham chiếu từ đây — không hardcode Color() ở nơi khác.
abstract final class AppColors {
  // ─── Brand ─────────────────────────────────────────────────────────────────
  static const Color primaryOrange   = Color(0xFFE85D24);
  static const Color primaryNavy     = Color(0xFF1A2A4A);
  static const Color secondaryOrange = Color(0xFFC0491A);

  // ─── Background ────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color surface         = Color(0xFFFFFFFF);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark  = Color(0xFF1A1A1A);
  static const Color textGray  = Color(0xFF9AA4B0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ─── Border / Divider ──────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE8ECF0);
  static const Color divider     = Color(0xFFE0E0E0);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF2E7D5E);
  static const Color errorRed     = Color(0xFFD32F2F);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue     = Color(0xFF1565C0);

  // ─── Order Status — foreground ─────────────────────────────────────────────
  /// pending      → xám       (chờ xác nhận)
  static const Color statusPending      = Color(0xFF9AA4B0);
  /// quoted       → xanh dương (đã báo giá)
  static const Color statusQuoted       = Color(0xFF1565C0);
  /// inProduction → cam        (đang sản xuất)
  static const Color statusInProduction = Color(0xFFE85D24);
  /// delivered    → xanh lá   (đã giao hàng)
  static const Color statusDelivered    = Color(0xFF2E7D5E);
  /// completed    → navy       (hoàn thành)
  static const Color statusCompleted    = Color(0xFF1A2A4A);

  // ─── Order Status — background (dùng cho Chip / Badge) ────────────────────
  static const Color statusPendingBg      = Color(0xFFF0F2F5);
  static const Color statusQuotedBg       = Color(0xFFE3EDF9);
  static const Color statusInProductionBg = Color(0xFFFDF0EC);
  static const Color statusDeliveredBg    = Color(0xFFE8F5F0);
  static const Color statusCompletedBg    = Color(0xFFE8ECF4);

  // ─── Helpers ───────────────────────────────────────────────────────────────
  /// Trả về màu text tương ứng với status string từ API.
  static Color forOrderStatus(String status) => switch (status.toLowerCase()) {
    'pending'          => statusPending,
    'quoted'           => statusQuoted,
    'in_production'    => statusInProduction,
    'delivered'        => statusDelivered,
    'completed'        => statusCompleted,
    'cancelled'        => errorRed,
    'cancelrequested'  => warningAmber,
    _                  => statusPending,
  };

  /// Trả về màu nền tương ứng với status string từ API.
  static Color bgForOrderStatus(String status) => switch (status.toLowerCase()) {
    'pending'          => statusPendingBg,
    'quoted'           => statusQuotedBg,
    'in_production'    => statusInProductionBg,
    'delivered'        => statusDeliveredBg,
    'completed'        => statusCompletedBg,
    'cancelled'        => const Color(0xFFFDECEC),
    'cancelrequested'  => const Color(0xFFFFF8E1),
    _                  => statusPendingBg,
  };
}
