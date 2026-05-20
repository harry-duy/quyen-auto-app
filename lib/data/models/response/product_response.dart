// Hand-written DTO — matches backend ProductResponse JSON exactly

class ProductResponse {
  final int id;
  final String? categoryName;
  final String name;
  final String? description;
  final double? basePrice;
  final List<String> imageUrls;
  final bool isActive;

  const ProductResponse({
    required this.id,
    this.categoryName,
    required this.name,
    this.description,
    this.basePrice,
    required this.imageUrls,
    required this.isActive,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(
        id: (json['id'] as num).toInt(),
        categoryName: json['categoryName'] as String?,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        basePrice: (json['basePrice'] as num?)?.toDouble(),
        imageUrls: (json['imageUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        isActive: json['isActive'] as bool? ?? true,
      );
}
