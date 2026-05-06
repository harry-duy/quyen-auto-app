// TODO: Pure domain entity — no JSON/framework dependencies

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final String? truckType;
  final double? length;
  final double? width;
  final double? height;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    this.truckType,
    this.length,
    this.width,
    this.height,
    required this.inStock,
  });
}
