import 'package:json_annotation/json_annotation.dart';
part 'quotation_request.g.dart';

@JsonSerializable()
class QuotationRequest {
  final int productId;
  final String weightRange;
  final String cargoType;
  final String? note;
  final String? vehicleBrand;
  final String? bodyType;
  final String? bodySize;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final List<String>? options;

  const QuotationRequest({
    required this.productId,
    required this.weightRange,
    required this.cargoType,
    this.note,
    this.vehicleBrand,
    this.bodyType,
    this.bodySize,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.options,
  });

  factory QuotationRequest.fromJson(Map<String, dynamic> json) =>
      _$QuotationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QuotationRequestToJson(this);
}
