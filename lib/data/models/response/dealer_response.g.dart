// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dealer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DealerResponse _$DealerResponseFromJson(Map<String, dynamic> json) =>
    DealerResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      province: json['province'] as String,
      phone: json['phone'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$DealerResponseToJson(DealerResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'province': instance.province,
      'phone': instance.phone,
      'lat': instance.lat,
      'lng': instance.lng,
    };
