/// Yêu cầu tạo báo giá thùng xe — gửi lên server
import 'dart:convert';

class QuotationRequest {
  final int productId;
  final String vehicleModel;
  final int quantity;
  final int? chassisWidth;
  final String? boxCode;
  final String? boxType;
  final String? acType;
  final String? acModel;
  final bool innerWallInsulated;

  /// JSON object chứa toàn bộ thông số kỹ thuật (phụ kiện, foam, option)
  final Map<String, dynamic> specifications;

  // Field cũ giữ lại để tương thích
  final String? weightRange;
  final String? cargoType;
  final String? note;

  const QuotationRequest({
    required this.productId,
    required this.vehicleModel,
    this.quantity = 1,
    this.chassisWidth,
    this.boxCode,
    this.boxType,
    this.acType,
    this.acModel,
    this.innerWallInsulated = false,
    this.specifications = const {},
    this.weightRange,
    this.cargoType,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'vehicleModel': vehicleModel,
    'quantity': quantity,
    if (chassisWidth != null) 'chassisWidth': chassisWidth,
    if (boxCode != null) 'boxCode': boxCode,
    if (boxType != null) 'boxType': boxType,
    if (acType != null) 'acType': acType,
    if (acModel != null) 'acModel': acModel,
    'innerWallInsulated': innerWallInsulated,
    if (specifications.isNotEmpty) 'specifications': jsonEncode(specifications),
    if (weightRange != null) 'weightRange': weightRange,
    if (cargoType != null) 'cargoType': cargoType,
    if (note != null) 'note': note,
  };
}
