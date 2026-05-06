// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductImageResponse _$ProductImageResponseFromJson(
  Map<String, dynamic> json,
) => ProductImageResponse(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  isPrimary: json['isPrimary'] as bool,
);

Map<String, dynamic> _$ProductImageResponseToJson(
  ProductImageResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'isPrimary': instance.isPrimary,
};

ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    ProductResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      weightCapacity: json['weightCapacity'] as String,
      description: json['description'] as String,
      priceRangeMin: (json['priceRangeMin'] as num).toDouble(),
      priceRangeMax: (json['priceRangeMax'] as num).toDouble(),
      images: (json['images'] as List<dynamic>)
          .map((e) => ProductImageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$ProductResponseToJson(ProductResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'weightCapacity': instance.weightCapacity,
      'description': instance.description,
      'priceRangeMin': instance.priceRangeMin,
      'priceRangeMax': instance.priceRangeMax,
      'images': instance.images,
      'isActive': instance.isActive,
    };
