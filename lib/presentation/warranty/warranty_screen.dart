import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/warranty_providers.dart';
import '../../data/models/response/warranty_response.dart';
import '../../domain/entities/warranty.dart';

// kBottomNavigationBarHeight = 56
const _kNavBarH = kBottomNavigationBarHeight;

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Bảo hành'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Xe của tôi'),
              Tab(text: 'Yêu cầu bảo hành'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VehicleListTab(),
            _WarrantyRequestTab(),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: _kNavBarH),
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateRequestDialog(context, ref),
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Tạo yêu cầu'),
          ),
        ),
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateWarrantySheet(parentRef: ref),
    );
  }
}

// ─── Vehicle List Tab ─────────────────────────────────────────────────────────

class _VehicleListTab extends ConsumerWidget {
  const _VehicleListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);
    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return const _EmptyState(
            icon: Icons.directions_car_outlined,
            message: 'Chưa có xe nào được đăng ký',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myVehiclesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: vehicles.length,
            itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  static ({Color color, String text}) _warrantyStatus(Vehicle v) {
    if (v.warrantyExpiryDate == null) {
      return (color: AppColors.textGray, text: 'Không có bảo hành');
    }
    if (!v.isWarrantyActive) {
      return (color: AppColors.errorRed, text: 'Hết hạn bảo hành');
    }
    if (v.isWarrantyExpiringSoon) {
      return (color: AppColors.warningAmber, text: 'Sắp hết hạn');
    }
    return (color: AppColors.successGreen, text: 'Còn bảo hành');
  }

  @override
  Widget build(BuildContext context) {
    final status = _warrantyStatus(vehicle);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      color: AppColors.primaryNavy, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status.text,
                        style: TextStyle(
                            fontSize: 11,
                            color: status.color,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (vehicle.productName != null)
                _InfoRow(label: 'Mẫu xe', value: vehicle.productName!),
              _InfoRow(label: 'Số khung', value: vehicle.chassisNumber),
              if (vehicle.contractCode != null)
                _InfoRow(label: 'Mã hợp đồng', value: vehicle.contractCode!),
              if (vehicle.warrantyExpiryDate != null)
                _InfoRow(
                    label: 'Hết hạn BH',
                    value: vehicle.warrantyExpiryDate!,
                    valueColor: status.color),
              const SizedBox(height: 8),
              Row(children: [
                const Spacer(),
                Text('Xem chi tiết',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 11, color: AppColors.primaryOrange),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final status = _warrantyStatus(vehicle);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.directions_car,
                  color: AppColors.primaryNavy, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(vehicle.plateNumber,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: status.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.text,
                    style: TextStyle(
                        fontSize: 12,
                        color: status.color,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (vehicle.productName != null)
              _InfoRow(label: 'Mẫu xe / Thùng', value: vehicle.productName!),
            _InfoRow(label: 'Số khung', value: vehicle.chassisNumber),
            if (vehicle.contractCode != null)
              _InfoRow(label: 'Mã hợp đồng', value: vehicle.contractCode!),
            if (vehicle.warrantyExpiryDate != null)
              _InfoRow(
                  label: 'Ngày hết hạn BH',
                  value: vehicle.warrantyExpiryDate!,
                  valueColor: status.color),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Warranty Request Tab ─────────────────────────────────────────────────────

class _WarrantyRequestTab extends ConsumerWidget {
  const _WarrantyRequestTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warrantiesAsync = ref.watch(myWarrantiesProvider);
    return warrantiesAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.verified_user_outlined,
            message: 'Chưa có yêu cầu bảo hành nào',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myWarrantiesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (_, i) => _WarrantyCard(request: requests[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  final WarrantyRequestResponse request;
  const _WarrantyCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusMap = {
      'PENDING': ('Chờ xử lý', AppColors.warningAmber),
      'IN_PROGRESS': ('Đang xử lý', AppColors.infoBlue),
      'RESOLVED': ('Đã xử lý', AppColors.successGreen),
      'REJECTED': ('Từ chối', AppColors.errorRed),
    };
    final (statusLabel, statusColor) =
        statusMap[request.status] ?? (request.status, AppColors.textGray);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: statusColor.withAlpha(25),
          child: Icon(Icons.build_outlined, color: statusColor, size: 18),
        ),
        title: Text(
          'BH #${request.id} — ${request.plateNumber}',
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        subtitle: Text(
          request.issueDescription,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w600)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (request.scheduledDate != null)
                  _InfoRow(
                      label: 'Ngày hẹn', value: request.scheduledDate!),
                if (request.technicianName != null)
                  _InfoRow(
                      label: 'Kỹ thuật viên',
                      value: request.technicianName!),
                if (request.result != null && request.result!.isNotEmpty)
                  _InfoRow(label: 'Kết quả', value: request.result!),
                if (request.logs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Lịch sử xử lý',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGray)),
                  const SizedBox(height: 4),
                  ...request.logs.map((log) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle,
                                size: 6,
                                color: AppColors.primaryNavy),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${log.action}${log.note != null ? " — ${log.note}" : ""}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textDark),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Warranty Request Bottom Sheet ─────────────────────────────────────

class _CreateWarrantySheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _CreateWarrantySheet({required this.parentRef});

  @override
  ConsumerState<_CreateWarrantySheet> createState() =>
      _CreateWarrantySheetState();
}

class _CreateWarrantySheetState extends ConsumerState<_CreateWarrantySheet> {
  Vehicle? _selectedVehicle;
  final _issueController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedVehicle == null || _issueController.text.trim().isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(warrantyActionsProvider.notifier).createRequest(
            vehicleId: _selectedVehicle!.id,
            issueDescription: _issueController.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu bảo hành')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tạo yêu cầu bảo hành',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 16),
          vehiclesAsync.when(
            data: (vehicles) => DropdownButtonFormField<Vehicle>(
              value: _selectedVehicle,
              decoration: const InputDecoration(
                labelText: 'Chọn xe',
                border: OutlineInputBorder(),
              ),
              items: vehicles
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text('${v.plateNumber} — ${v.chassisNumber}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedVehicle = v),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) =>
                const Text('Không tải được danh sách xe'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _issueController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả sự cố',
              hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Gửi yêu cầu',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textGray)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12,
                    color: valueColor ?? AppColors.textDark,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGray, size: 48),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textGray, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.errorRed, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(color: AppColors.errorRed),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
