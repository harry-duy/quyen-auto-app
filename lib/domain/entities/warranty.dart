// TODO: Pure domain entity — no JSON/framework dependencies

class Vehicle {
  final String id;
  final String plateNumber;
  final String truckType;
  final DateTime purchaseDate;
  final DateTime warrantyExpiry;
  final String? bodySerialNumber;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.truckType,
    required this.purchaseDate,
    required this.warrantyExpiry,
    this.bodySerialNumber,
  });

  bool get isWarrantyActive => warrantyExpiry.isAfter(DateTime.now());
}
