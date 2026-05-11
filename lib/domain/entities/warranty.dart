class Vehicle {
  final String  id;
  final String  plateNumber;
  final String  chassisNumber;
  final DateTime? purchaseDate;
  final String? productName;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.chassisNumber,
    this.purchaseDate,
    this.productName,
  });
}
