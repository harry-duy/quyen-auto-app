import '../entities/warranty.dart';
import '../../data/models/response/warranty_response.dart';

abstract class WarrantyRepository {
  Future<List<Vehicle>> getMyVehicles();
  Future<List<WarrantyRequestResponse>> getMyWarranties();
  Future<WarrantyRequestResponse> createWarrantyRequest({
    required int vehicleId,
    required String issueDescription,
    String? scheduledDate,
    List<String>? imageUrls,
  });
}
