import 'package:json_annotation/json_annotation.dart';
part 'product_response.g.dart';

/// Matches backend ProductResponse DTO exactly:
/// id, categoryId, categoryName, name, description,
/// specifications, basePrice, isActive, imageUrls
@JsonSerializable()
class ProductResponse {
  final int     id;
  final int?    categoryId;
  final String? categoryName;
  final String  name;
  final String  description;
  final String? specifications;
  final double  basePrice;
  final bool    isActive;
  final List<String> imageUrls;

  const ProductResponse({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.description,
    this.specifications,
    required this.basePrice,
    required this.isActive,
    required this.imageUrls,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}
