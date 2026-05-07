import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/order_response.dart';

class QuotationApprovalScreen extends ConsumerWidget {
  const QuotationApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(staffQuotationListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Duyệt báo giá')),
      body: quotationsAsync.when(
        data: (quotations) {
          if (quotations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppColors.successGreen, size: 48),
                  SizedBox(height: 8),
                  Text('Không có báo giá chờ duyệt',
                      style:
                          TextStyle(color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(staffQuotationListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: quotations.length,
              itemBuilder: (_, i) =>
                  _QuotationCard(quotation: quotations[i]),
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

class _QuotationCard extends ConsumerWidget {
  final QuotationResponse quotation;
  const _QuotationCard({required this.quotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

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
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.request_quote,
                  color: AppColors.warningAmber, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Báo giá #${quotation.id}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(dateFmt.format(quotation.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGray)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('PENDING',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningAmber)),
            ),
          ]),
          const SizedBox(height: 12),
          _DetailRow(label: 'Sản phẩm',
              value: quotation.product?.name ?? 'N/A'),
          _DetailRow(label: 'Tải trọng', value: quotation.weightRange),
          _DetailRow(label: 'Loại hàng', value: quotation.cargoType),
          if (quotation.note != null)
            _DetailRow(label: 'Ghi chú', value: quotation.note!),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showApprovalDialog(context, ref),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Gửi báo giá'),
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, WidgetRef ref) {
    final priceController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Báo giá #${quotation.id}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                  if (double.tryParse(v.replaceAll(',', '')) == null) {
                    return 'Giá không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final price = double.parse(
                  priceController.text.replaceAll(',', ''));
              Navigator.pop(ctx);
              try {
                await ref
                    .read(staffActionsProvider.notifier)
                    .approveQuotation(
                      quotation.id.toString(),
                      price,
                      noteController.text.isEmpty
                          ? null
                          : noteController.text,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi báo giá thành công')),
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
            child: const Text('Gửi báo giá'),
          ),
        ],
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
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
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
