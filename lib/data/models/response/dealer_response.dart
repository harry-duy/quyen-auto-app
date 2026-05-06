import 'package:json_annotation/json_annotation.dart';
part 'dealer_response.g.dart';

@JsonSerializable()
class DealerResponse {
  final int    id;
  final String name;
  final String address;
  final String province;
  final String phone;
  final double lat;
  final double lng;

  const DealerResponse({
    required this.id,
    required this.name,
    required this.address,
    required this.province,
    required this.phone,
    required this.lat,
    required this.lng,
  });

  factory DealerResponse.fromJson(Map<String, dynamic> json) =>
      _$DealerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DealerResponseToJson(this);
}
