class LeadResponse {
  final int id;
  final String phone;
  final String? name;
  final int? productId;
  final String? productName;
  final String? note;
  final String? specifications;
  final bool contacted;
  final DateTime createdAt;

  const LeadResponse({
    required this.id,
    required this.phone,
    this.name,
    this.productId,
    this.productName,
    this.note,
    this.specifications,
    required this.contacted,
    required this.createdAt,
  });

  factory LeadResponse.fromJson(Map<String, dynamic> json) => LeadResponse(
        id: (json['id'] as num).toInt(),
        phone: json['phone'] as String,
        name: json['name'] as String?,
        productId: (json['productId'] as num?)?.toInt(),
        productName: json['productName'] as String?,
        note: json['note'] as String?,
        specifications: json['specifications'] as String?,
        contacted: json['contacted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
