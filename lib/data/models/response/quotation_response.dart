class StaffQuotationResponse {
  final int id;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? guestName;
  final String? guestPhone;
  final int? templateId;
  final String? templateName;
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
  final double? basePrice;
  final double? optionTotal;
  final double? estimatedTotal;
  final double? adjustmentFee;
  final double? discountAmount;
  final double? approvedTotal;
  final String? priceNote;
  final String? technicalNote;
  final String? revisionNote;
  final List<SelectedQuotationOptionResponse> selectedOptions;
  final String status;
  final int? staffId;
  final String? staffName;
  final String? staffNote;
  final int? contactedById;
  final String? contactedByName;
  final DateTime? contactedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ── Staff-created flow ─────────────────────────────────────────────────
  final bool? isStaffCreated;
  final bool? isNewProductRequest;
  final String? newProductDescription;
  final int? approvedById;
  final String? approvedByName;
  final DateTime? approvedAt;
  final DateTime? sentAt;

  bool get isContacted => contactedAt != null;
  bool get isPending => status == 'PENDING';
  bool get isQuoted => status == 'QUOTED';

  // ── Flow mới ───────────────────────────────────────────────────────────
  bool get isDraft => status == 'DRAFT';
  bool get isPendingApproval => status == 'PENDING_APPROVAL';
  bool get isWaitingTechnicalReview => status == 'WAITING_TECHNICAL_REVIEW';
  bool get isNeedRevision => status == 'NEED_REVISION';
  bool get isApproved => status == 'APPROVED';
  bool get isSent => status == 'SENT';
  bool get isContractPending => status == 'CONTRACT_PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isCustomerRejected => status == 'CUSTOMER_REJECTED';

  const StaffQuotationResponse({
    required this.id,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.guestName,
    this.guestPhone,
    this.templateId,
    this.templateName,
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
    this.basePrice,
    this.optionTotal,
    this.estimatedTotal,
    this.adjustmentFee,
    this.discountAmount,
    this.approvedTotal,
    this.priceNote,
    this.technicalNote,
    this.revisionNote,
    this.selectedOptions = const [],
    required this.status,
    this.staffId,
    this.staffName,
    this.staffNote,
    this.contactedById,
    this.contactedByName,
    this.contactedAt,
    this.isStaffCreated,
    this.isNewProductRequest,
    this.newProductDescription,
    this.approvedById,
    this.approvedByName,
    this.approvedAt,
    this.sentAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory StaffQuotationResponse.fromJson(Map<String, dynamic> json) {
    return StaffQuotationResponse(
      id: json['id'] as int,
      customerId: json['customerId'] as int?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      guestName: json['guestName'] as String?,
      guestPhone: json['guestPhone'] as String?,
      templateId: json['templateId'] as int?,
      templateName: json['templateName'] as String?,
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
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      optionTotal: (json['optionTotal'] as num?)?.toDouble(),
      estimatedTotal: (json['estimatedTotal'] as num?)?.toDouble(),
      adjustmentFee: (json['adjustmentFee'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      approvedTotal: (json['approvedTotal'] as num?)?.toDouble(),
      priceNote: json['priceNote'] as String?,
      technicalNote: json['technicalNote'] as String?,
      revisionNote: json['revisionNote'] as String?,
      selectedOptions:
          (json['selectedOptions'] as List<dynamic>?)
              ?.map(
                (e) => SelectedQuotationOptionResponse.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      status: json['status'] as String,
      staffId: json['staffId'] as int?,
      staffName: json['staffName'] as String?,
      staffNote: json['staffNote'] as String?,
      contactedById: json['contactedById'] as int?,
      contactedByName: json['contactedByName'] as String?,
      contactedAt: json['contactedAt'] == null
          ? null
          : DateTime.parse(json['contactedAt'] as String),
      isStaffCreated: json['isStaffCreated'] as bool?,
      isNewProductRequest: json['isNewProductRequest'] as bool?,
      newProductDescription: json['newProductDescription'] as String?,
      approvedById: json['approvedById'] as int?,
      approvedByName: json['approvedByName'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class SelectedQuotationOptionResponse {
  final int id;
  final int? optionId;
  final String name;
  final String position;
  final String unit;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double? managerOverridePrice;
  final String? note;
  final bool isCustom;

  const SelectedQuotationOptionResponse({
    required this.id,
    this.optionId,
    required this.name,
    required this.position,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.managerOverridePrice,
    this.note,
    required this.isCustom,
  });

  factory SelectedQuotationOptionResponse.fromJson(Map<String, dynamic> json) {
    return SelectedQuotationOptionResponse(
      id: json['id'] as int,
      optionId: json['optionId'] as int?,
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? 'OTHER',
      unit: json['unit'] as String? ?? 'cai',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      managerOverridePrice: (json['managerOverridePrice'] as num?)?.toDouble(),
      note: json['note'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
