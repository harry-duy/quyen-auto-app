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
    final pendingCount = ref.watch(staffPendingQuoteCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Duyệt báo giá'),
        actions: [
          pendingCount.when(
            data: (count) => count > 0
                ? Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Badge(
                      label: Text('$count'),
                      backgroundColor: AppColors.errorRed,
                      child: const Icon(Icons.notifications_active),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
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
            onRefresh: () async {
              ref.invalidate(staffQuotationListProvider);
              ref.invalidate(staffPendingQuoteCountProvider);
            },
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(staffQuotationListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
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
    final isContacted = quotation.contacted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContacted ? AppColors.borderLight : AppColors.warningAmber,
          width: isContacted ? 1 : 1.5,
        ),
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
                color: isContacted
                    ? AppColors.successGreen.withValues(alpha: 0.12)
                    : AppColors.warningAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isContacted ? Icons.check_circle : Icons.request_quote,
                color: isContacted
                    ? AppColors.successGreen
                    : AppColors.warningAmber,
                size: 20,
              ),
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
            if (!isContacted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.priority_high, size: 14, color: AppColors.errorRed),
                    SizedBox(width: 2),
                    Text('Chưa liên hệ',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorRed)),
                  ],
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Đã liên hệ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successGreen)),
              ),
          ]),

          const Divider(height: 20),

          // Customer info
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Khách hàng',
            value: quotation.customerName ?? 'N/A',
          ),
          if (quotation.customerPhone != null)
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Điện thoại',
              value: quotation.customerPhone!,
            ),

          const SizedBox(height: 8),

          // Vehicle spec
          _DetailRow(
            icon: Icons.local_shipping_outlined,
            label: 'Sản phẩm',
            value: quotation.productName ?? quotation.product?.name ?? 'N/A',
          ),
          if (quotation.vehicleBrand != null)
            _DetailRow(
              icon: Icons.directions_car_outlined,
              label: 'Hãng xe',
              value: quotation.vehicleBrand!,
            ),
          if (quotation.bodyType != null)
            _DetailRow(
              icon: Icons.inventory_2_outlined,
              label: 'Loại thùng',
              value: quotation.bodyType!,
            ),
          if (quotation.bodySize != null)
            _DetailRow(
              icon: Icons.straighten_outlined,
              label: 'Size thùng',
              value: quotation.bodySize!,
            ),
          if (quotation.lengthCm != null ||
              quotation.widthCm != null ||
              quotation.heightCm != null)
            _DetailRow(
              icon: Icons.aspect_ratio_outlined,
              label: 'Kích thước',
              value:
                  '${quotation.lengthCm?.toStringAsFixed(0) ?? '?'} × ${quotation.widthCm?.toStringAsFixed(0) ?? '?'} × ${quotation.heightCm?.toStringAsFixed(0) ?? '?'} cm',
            ),
          if (quotation.options != null && quotation.options!.isNotEmpty)
            _DetailRow(
              icon: Icons.build_outlined,
              label: 'Option',
              value: quotation.options!.join(', '),
            ),
          if (quotation.note != null)
            _DetailRow(
              icon: Icons.notes_outlined,
              label: 'Ghi chú',
              value: quotation.note!,
            ),

          if (isContacted && quotation.contactedByName != null) ...[
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Người nhận',
              value: quotation.contactedByName!,
            ),
          ],

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              if (!isContacted)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _markContacted(context, ref),
                    icon: const Icon(Icons.phone_callback, size: 18),
                    label: const Text('Đã liên hệ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.successGreen,
                      side: const BorderSide(color: AppColors.successGreen),
                    ),
                  ),
                ),
              if (!isContacted) const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showApprovalDialog(context, ref),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Gửi báo giá'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _markContacted(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .markQuotationContacted(quotation.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu liên hệ thành công'),
            backgroundColor: AppColors.successGreen,
          ),
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
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textGray),
          const SizedBox(width: 6),
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
