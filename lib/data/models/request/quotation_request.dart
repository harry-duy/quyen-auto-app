import 'package:json_annotation/json_annotation.dart';
part 'quotation_request.g.dart';

@JsonSerializable()
class QuotationRequest {
  final int     productId;
  final String  weightRange;
  final String  cargoType;
  final String? note;

  const QuotationRequest({
    required this.productId,
    required this.weightRange,
    required this.cargoType,
    this.note,
  });

  factory QuotationRequest.fromJson(Map<String, dynamic> json) =>
      _$QuotationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QuotationRequestToJson(this);
}
