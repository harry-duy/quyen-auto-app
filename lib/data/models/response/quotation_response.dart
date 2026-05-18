class StaffQuotationResponse {
  final int id;
  final int customerId;
  final String? customerName;
  final String? customerPhone;
  final int? productId;
  final String? productName;
  final String? vehicleModel;
  final int? quantity;
  final int? chassisWidth;
  final String? boxCode;
  final String? boxType;
  final String? acType;
  final String? acModel;
  final bool? innerWallInsulated;
  final String? specifications;
  final String? weightRange;
  final String? cargoType;
  final String? note;
  final double? quotedPrice;
  final String status;
  final int? staffId;
  final String? staffName;
  final String? staffNote;
  final int? contactedById;
  final String? contactedByName;
  final DateTime? contactedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isContacted => contactedAt != null;
  bool get isPending => status == 'PENDING';
  bool get isQuoted => status == 'QUOTED';

  const StaffQuotationResponse({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.productId,
    this.productName,
    this.vehicleModel,
    this.quantity,
    this.chassisWidth,
    this.boxCode,
    this.boxType,
    this.acType,
    this.acModel,
    this.innerWallInsulated,
    this.specifications,
    this.weightRange,
    this.cargoType,
    this.note,
    this.quotedPrice,
    required this.status,
    this.staffId,
    this.staffName,
    this.staffNote,
    this.contactedById,
    this.contactedByName,
    this.contactedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory StaffQuotationResponse.fromJson(Map<String, dynamic> json) {
    return StaffQuotationResponse(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      productId: json['productId'] as int?,
      productName: json['productName'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      quantity: json['quantity'] as int?,
      chassisWidth: json['chassisWidth'] as int?,
      boxCode: json['boxCode'] as String?,
      boxType: json['boxType'] as String?,
      acType: json['acType'] as String?,
      acModel: json['acModel'] as String?,
      innerWallInsulated: json['innerWallInsulated'] as bool?,
      specifications: json['specifications'] as String?,
      weightRange: json['weightRange'] as String?,
      cargoType: json['cargoType'] as String?,
      note: json['note'] as String?,
      quotedPrice: (json['quotedPrice'] as num?)?.toDouble(),
      status: json['status'] as String,
      staffId: json['staffId'] as int?,
      staffName: json['staffName'] as String?,
      staffNote: json['staffNote'] as String?,
      contactedById: json['contactedById'] as int?,
      contactedByName: json['contactedByName'] as String?,
      contactedAt: json['contactedAt'] == null
          ? null
          : DateTime.parse(json['contactedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}
