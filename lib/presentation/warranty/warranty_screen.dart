import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/warranty_providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/response/warranty_response.dart';
import '../../domain/entities/warranty.dart';

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync   = ref.watch(myVehiclesProvider);
    final warrantiesAsync = ref.watch(myWarrantyListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Bảo hành'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(myVehiclesProvider);
              ref.invalidate(myWarrantyListProvider);
            },
          ),
        ],
      ),
      floatingActionButton: vehiclesAsync.valueOrNull?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(
                  context, ref, vehiclesAsync.valueOrNull!),
              icon: const Icon(Icons.add),
              label: const Text('Yêu cầu bảo hành'),
              backgroundColor: AppColors.primaryOrange,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myVehiclesProvider);
          ref.invalidate(myWarrantyListProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Xe của tôi ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Xe của tôi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.vehicleList),
                      icon: const Icon(Icons.directions_car_outlined,
                          size: 15, color: AppColors.primaryOrange),
                      label: const Text('Xem tất cả',
                          style: TextStyle(
                              color: AppColors.primaryOrange, fontSize: 13)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: vehiclesAsync.when(
                  data: (vehicles) => vehicles.isEmpty
                      ? _EmptySection(
                          icon: Icons.directions_car_outlined,
                          message: 'Chưa có xe nào được đăng ký',
                          actionLabel: 'Liên hệ đăng ký xe',
                          onAction: () => context.push(AppRoutes.vehicleList),
                        )
                      : SizedBox(
                          height: 104,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: vehicles.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) =>
                                _VehicleCard(vehicle: vehicles[i]),
                          ),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text('$e',
                        style: const TextStyle(
                            color: AppColors.errorRed, fontSize: 12)),
                  ),
                ),
              ),
            ),

            // ── Lịch sử bảo hành ──────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Lịch sử yêu cầu bảo hành',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            warrantiesAsync.when(
              data: (list) => list.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptySection(
                        icon: Icons.build_circle_outlined,
                        message: 'Chưa có yêu cầu bảo hành nào',
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _WarrantyTile(warranty: list[i]),
                        childCount: list.length,
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('$e',
                      style:
                          const TextStyle(color: AppColors.errorRed)),
                ),
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, WidgetRef ref, List<Vehicle> vehicles) {
    Vehicle? selectedVehicle;
    final issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Yêu cầu bảo hành'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Vehicle>(
                decoration: const InputDecoration(
                  labelText: 'Chọn xe',
                  border: OutlineInputBorder(),
                ),
                items: vehicles
                    .map((v) => DropdownMenuItem<Vehicle>(
                          value: v,
                          child: Text(v.plateNumber,
                              style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedVehicle = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: issueController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Mô tả sự cố / vấn đề cần bảo hành',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedVehicle == null
                  ? null
                  : () async {
                      final issue = issueController.text.trim();
                      if (issue.isEmpty) return;
                      Navigator.pop(ctx);
                      try {
                        await ref
                            .read(warrantyActionsProvider.notifier)
                            .createWarrantyRequest(
                              vehicleId: selectedVehicle!.id,
                              issueDescription: issue,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Đã gửi yêu cầu bảo hành')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: AppColors.errorRed),
                          );
                        }
                      }
                    },
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vehicle card (horizontal list) ──────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car,
                  color: AppColors.primaryNavy, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vehicle.plateNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          if (vehicle.productName != null)
            Text(
              vehicle.productName!,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            'Khung: ${vehicle.chassisNumber.isEmpty ? 'N/A' : vehicle.chassisNumber}',
            style: const TextStyle(fontSize: 11, color: AppColors.textGray),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Warranty request tile ────────────────────────────────────────────────────

class _WarrantyTile extends StatelessWidget {
  final WarrantyRequestResponse warranty;
  const _WarrantyTile({required this.warranty});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) =
        switch (warranty.status.toUpperCase()) {
      'PENDING'     => ('Chờ xử lý', AppColors.warningAmber),
      'IN_PROGRESS' => ('Đang xử lý', AppColors.infoBlue),
      'RESOLVED'    => ('Đã xử lý', AppColors.successGreen),
      'REJECTED'    => ('Từ chối', AppColors.errorRed),
      _             => ('Không rõ', AppColors.textGray),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.build_circle, color: statusColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BH #${warranty.id}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  Text(warranty.vehicle.plateNumber,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGray)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ]),
          const SizedBox(height: 8),

          // Issue description
          Text(
            warranty.issueDescription,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textGray),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Scheduled date
          if (warranty.scheduledDate != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppColors.infoBlue),
              const SizedBox(width: 4),
              Text(
                'Lịch hẹn: ${warranty.scheduledDate}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.infoBlue),
              ),
            ]),
          ],

          // Logs summary
          if (warranty.logs.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              warranty.logs.last.action +
                  (warranty.logs.last.note != null
                      ? ' — ${warranty.logs.last.note}'
                      : ''),
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGray,
                  fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Empty section widget ─────────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptySection({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGray, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textGray, fontSize: 13)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!,
                  style: const TextStyle(
                      color: AppColors.primaryOrange, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
