import '../../domain/entities/warranty.dart';
import '../../domain/repositories/warranty_repository.dart';
import '../models/response/warranty_response.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class WarrantyRepositoryImpl implements WarrantyRepository {
  final ApiService _api;

  WarrantyRepositoryImpl(this._api);

  @override
  Future<List<Vehicle>> getMyVehicles() async {
    final res = await _api.get<List<Vehicle>>(
      ApiConstants.vehicles,
      fromData: (json) {
        final list = json is List ? json : (json as Map<String, dynamic>)['data'] as List? ?? [];
        return list.map((e) {
          final v = VehicleResponse.fromJson(e as Map<String, dynamic>);
          return Vehicle(
            id: v.id,
            ownerId: v.ownerId,
            ownerName: v.ownerName,
            productId: v.productId,
            productName: v.productName,
            plateNumber: v.plateNumber,
            chassisNumber: v.chassisNumber,
            purchaseDate: v.purchaseDate,
            contractCode: v.contractCode,
            warrantyExpiryDate: v.warrantyExpiryDate,
          );
        }).toList();
      },
    );
    return res.data ?? [];
  }

  @override
  Future<List<WarrantyRequestResponse>> getMyWarranties() async {
    final res = await _api.get<List<WarrantyRequestResponse>>(
      ApiConstants.warrantyRequests,
      fromData: (json) {
        final List<dynamic> list;
        if (json is List) {
          list = json;
        } else {
          final map = json as Map<String, dynamic>;
          if (map.containsKey('content')) {
            list = (map['content'] as List?) ?? [];
          } else {
            final data = map['data'];
            list = data is Map ? (data['content'] as List?) ?? [] : data as List? ?? [];
          }
        }
        return list
            .map((e) => WarrantyRequestResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return res.data ?? [];
  }

  @override
  Future<WarrantyRequestResponse> createWarrantyRequest({
    required int vehicleId,
    required String issueDescription,
    String? scheduledDate,
    List<String>? imageUrls,
  }) async {
    final res = await _api.post<WarrantyRequestResponse>(
      ApiConstants.warrantyRequests,
      data: {
        'vehicleId': vehicleId,
        'issueDescription': issueDescription,
        if (scheduledDate != null) 'scheduledDate': scheduledDate,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      },
      fromData: (json) {
        final map = json as Map<String, dynamic>;
        return WarrantyRequestResponse.fromJson(
          map['data'] as Map<String, dynamic>? ?? map,
        );
      },
    );
    return res.data!;
  }
}
