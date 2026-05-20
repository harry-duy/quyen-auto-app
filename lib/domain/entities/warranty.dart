class Vehicle {
  final int id;
  final int ownerId;
  final String ownerName;
  final int? productId;
  final String? productName;
  final String plateNumber;
  final String chassisNumber;
  final String purchaseDate;
  final String? contractCode;
  final String? warrantyExpiryDate;

  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.productId,
    this.productName,
    required this.plateNumber,
    required this.chassisNumber,
    required this.purchaseDate,
    this.contractCode,
    this.warrantyExpiryDate,
  });

  bool get isWarrantyActive {
    if (warrantyExpiryDate == null) return false;
    return DateTime.parse(warrantyExpiryDate!).isAfter(DateTime.now());
  }

  bool get isWarrantyExpiringSoon {
    if (warrantyExpiryDate == null) return false;
    final expiry = DateTime.parse(warrantyExpiryDate!);
    final diff = expiry.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 30;
  }
}
