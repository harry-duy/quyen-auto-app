import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/warranty_response.dart';
import '../../domain/entities/warranty.dart';
import 'service_providers.dart';

// ─── Customer: vehicle list ───────────────────────────────────────────────────

final myVehiclesProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  final repo = ref.watch(warrantyRepositoryProvider);
  return repo.getMyVehicles();
});

// ─── Customer: warranty request list ─────────────────────────────────────────

final myWarrantyListProvider =
    FutureProvider.autoDispose<List<WarrantyRequestResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<WarrantyRequestResponse>>(
    ApiConstants.warrantyRequests,
    queryParams: {'page': 0, 'size': 50},
    fromData: (json) {
      final list = json is Map<String, dynamic> && json['content'] is List
          ? json['content'] as List
          : json as List;
      return list
          .map((e) =>
              WarrantyRequestResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
  return res.data ?? [];
});

// ─── Customer: warranty actions ───────────────────────────────────────────────

class WarrantyActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> createWarrantyRequest({
    required String vehicleId,
    required String issueDescription,
  }) async {
    final repo = ref.read(warrantyRepositoryProvider);
    await repo.requestWarranty(
        vehicleId: vehicleId, issue: issueDescription);
    ref.invalidate(myWarrantyListProvider);
  }
}

final warrantyActionsProvider =
    NotifierProvider<WarrantyActionsNotifier, void>(
        WarrantyActionsNotifier.new);
