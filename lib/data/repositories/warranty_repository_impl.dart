import '../../domain/entities/warranty.dart';
import '../../domain/repositories/warranty_repository.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class WarrantyRepositoryImpl implements WarrantyRepository {
  final ApiService _api;

  WarrantyRepositoryImpl(this._api);

  Vehicle _mapVehicle(Map<String, dynamic> v) => Vehicle(
    id:               v['id']              as String,
    plateNumber:      v['plateNumber']     as String,
    truckType:        v['truckType']       as String,
    purchaseDate:     DateTime.parse(v['purchaseDate']   as String),
    warrantyExpiry:   DateTime.parse(v['warrantyExpiry'] as String),
    bodySerialNumber: v['bodySerialNumber'] as String?,
  );

  @override
  Future<List<Vehicle>> getMyVehicles() async {
    final res = await _api.get<List<Vehicle>>(
      ApiConstants.vehicles,
      fromData: (json) => (json as List)
          .map((e) => _mapVehicle(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data ?? [];
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    final res = await _api.get<Vehicle>(
      '${ApiConstants.vehicles}/$id',
      fromData: (json) => _mapVehicle(json as Map<String, dynamic>),
    );
    return res.data!;
  }

  @override
  Future<void> requestWarranty({
    required String vehicleId,
    required String issue,
    String? imageUrl,
  }) async {
    await _api.post<void>(
      ApiConstants.warrantyRequests,
      data: {
        'vehicleId': vehicleId,
        'issue':     issue,
        'imageUrl': ?imageUrl,
      },
    );
  }
}
