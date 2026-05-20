import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/warranty_response.dart';

class WarrantyManagementScreen extends ConsumerWidget {
  const WarrantyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warrantyAsync = ref.watch(staffWarrantyListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Quản lý bảo hành')),
      body: warrantyAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: AppColors.successGreen, size: 48),
                  SizedBox(height: 8),
                  Text('Không có yêu cầu bảo hành',
                      style:
                          TextStyle(color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(staffWarrantyListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (_, i) =>
                  _WarrantyCard(warranty: requests[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 40),
              const SizedBox(height: 8),
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarrantyCard extends ConsumerWidget {
  final WarrantyRequestResponse warranty;
  const _WarrantyCard({required this.warranty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    final (statusLabel, statusColor) = switch (warranty.status.toUpperCase()) {
      'PENDING' => ('Chờ xử lý', AppColors.warningAmber),
      'IN_PROGRESS' => ('Đang xử lý', AppColors.infoBlue),
      'RESOLVED' => ('Đã xử lý', AppColors.successGreen),
      'REJECTED' => ('Từ chối', AppColors.errorRed),
      _ => ('Không rõ', AppColors.textGray),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.build_circle, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BH #${warranty.id}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(warranty.vehicle.plateNumber,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGray)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 12),

          // Details
          _DetailRow(label: 'Biển số', value: warranty.vehicle.plateNumber),
          _DetailRow(label: 'Số khung', value: warranty.vehicle.chassisNumber),
          _DetailRow(label: 'Mô tả', value: warranty.issueDescription),
          if (warranty.scheduledDate != null)
            _DetailRow(
                label: 'Lịch hẹn',
                value: dateFmt.format(warranty.scheduledDate!)),
          const SizedBox(height: 12),

          // Actions
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showAssignDialog(context, ref),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Phân công'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showResultDialog(context, ref),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Kết quả'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
          ]),

          // Logs
          if (warranty.logs.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Lịch sử xử lý',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            ...warranty.logs.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.circle,
                        size: 6, color: AppColors.textGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${log.action}${log.note != null ? " — ${log.note}" : ""}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGray),
                      ),
                    ),
                    Text(dateFmt.format(log.createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textGray)),
                  ]),
                )),
          ],
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    final techController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phân công — BH #${warranty.id}'),
        content: TextField(
          controller: techController,
          decoration: const InputDecoration(
            labelText: 'Tên kỹ thuật viên',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (techController.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref
                    .read(staffActionsProvider.notifier)
                    .assignWarrantyTechnician(
                      warranty.id.toString(),
                      techController.text,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã phân công kỹ thuật viên')),
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
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, WidgetRef ref) {
    String? selectedResult;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Kết quả — BH #${warranty.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedResult,
                decoration: const InputDecoration(
                  labelText: 'Kết quả',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                      value: 'RESOLVED', child: Text('Đã xử lý xong')),
                  DropdownMenuItem<String>(
                      value: 'REJECTED', child: Text('Từ chối bảo hành')),
                  DropdownMenuItem<String>(
                      value: 'IN_PROGRESS',
                      child: Text('Đang tiếp tục xử lý')),
                ],
                onChanged: (v) => setState(() => selectedResult = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú kết quả',
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
              onPressed: selectedResult == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      try {
                        await ref
                            .read(staffActionsProvider.notifier)
                            .updateWarrantyResult(
                              warranty.id.toString(),
                              selectedResult!,
                              noteController.text.isEmpty
                                  ? null
                                  : noteController.text,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Đã cập nhật kết quả bảo hành')),
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
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textGray)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
