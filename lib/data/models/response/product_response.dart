import 'package:json_annotation/json_annotation.dart';
part 'product_response.g.dart';

@JsonSerializable()
class ProductImageResponse {
  final int    id;
  final String url;
  final bool   isPrimary;

  const ProductImageResponse({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory ProductImageResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductImageResponseToJson(this);
}

@JsonSerializable()
class ProductResponse {
  final int                    id;
  final String                 name;
  final String                 category;
  final String                 weightCapacity;
  final String                 description;
  final double                 priceRangeMin;
  final double                 priceRangeMax;
  final List<ProductImageResponse> images;
  final bool                   isActive;

  const ProductResponse({
    required this.id,
    required this.name,
    required this.category,
    required this.weightCapacity,
    required this.description,
    required this.priceRangeMin,
    required this.priceRangeMax,
    required this.images,
    required this.isActive,
  });

  /// URL ảnh đại diện (primary hoặc ảnh đầu tiên)
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    return images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    ).url;
  }

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}
