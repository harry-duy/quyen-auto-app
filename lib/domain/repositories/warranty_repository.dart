import '../entities/warranty.dart';

abstract class WarrantyRepository {
  Future<List<Vehicle>> getMyVehicles();
  Future<Vehicle> getVehicleById(String id);
  Future<void> requestWarranty({required String vehicleId, required String issue, String? imageUrl});
}
