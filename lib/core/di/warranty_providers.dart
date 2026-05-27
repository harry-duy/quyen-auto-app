import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/response/warranty_response.dart';
import '../../domain/entities/warranty.dart';
import 'service_providers.dart';

final myVehiclesProvider = FutureProvider.autoDispose<List<Vehicle>>((ref) {
  final repo = ref.watch(warrantyRepositoryProvider);
  return repo.getMyVehicles();
});

final myWarrantiesProvider =
    FutureProvider.autoDispose<List<WarrantyRequestResponse>>((ref) {
  final repo = ref.watch(warrantyRepositoryProvider);
  return repo.getMyWarranties();
});

class WarrantyActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> createRequest({
    required int vehicleId,
    required String issueDescription,
    String? scheduledDate,
    List<String>? imageUrls,
  }) async {
    final repo = ref.read(warrantyRepositoryProvider);
    await repo.createWarrantyRequest(
      vehicleId: vehicleId,
      issueDescription: issueDescription,
      scheduledDate: scheduledDate,
      imageUrls: imageUrls,
    );
    ref.invalidate(myWarrantiesProvider);
  }
}

final warrantyActionsProvider =
    NotifierProvider<WarrantyActionsNotifier, void>(WarrantyActionsNotifier.new);
