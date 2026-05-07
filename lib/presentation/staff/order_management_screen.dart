import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../core/router/staff_router.dart';
import '../../domain/entities/order.dart';

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key});

  static const _statusFilters = <String?>[
    null,
    'PENDING',
    'CONFIRMED',
    'IN_PRODUCTION',
    'COMPLETED',
    'CANCELLED',
  ];

  static const _statusLabels = <String>[
    'Tất cả',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đang sản xuất',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(staffOrderStatusFilter);
    final ordersAsync = ref.watch(staffOrderListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Quản lý đơn hàng')),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(_statusFilters.length, (i) {
                  final isSelected = currentFilter == _statusFilters[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(_statusLabels[i]),
                      selectedColor: AppColors.primaryOrange.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primaryOrange,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.textGray,
                      ),
                      onSelected: (_) => ref
                          .read(staffOrderStatusFilter.notifier)
                          .state = _statusFilters[i],
                    ),
                  );
                }),
              ),
            ),
          ),
          const Divider(height: 1),

          // Order list
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            color: AppColors.textGray, size: 48),
                        SizedBox(height: 8),
                        Text('Không có đơn hàng',
                            style: TextStyle(
                                color: AppColors.textGray, fontSize: 14)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(staffOrderListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(staffOrderListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Dismissible(
      key: ValueKey(order.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _showStatusUpdateSheet(context, ref, order);
        } else {
          context.push(StaffRoutes.orderOf(order.id));
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.infoBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.visibility, color: Colors.white),
            SizedBox(width: 8),
            Text('Chi tiết',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Cập nhật',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.edit, color: Colors.white),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => context.push(StaffRoutes.orderOf(order.id)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(order.orderCode,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ),
                _StatusChip(status: order.status),
              ]),
              const SizedBox(height: 8),
              Text(order.productName,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmt.format(order.totalAmount),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOrange)),
                  Text(dateFmt.format(order.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGray)),
                ],
              ),
              if (order.note != null) ...[
                const SizedBox(height: 6),
                Text('Ghi chú: ${order.note}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                        fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      OrderStatus.pending => ('Chờ xác nhận', AppColors.statusPending, AppColors.statusPendingBg),
      OrderStatus.confirmed => ('Đã xác nhận', AppColors.statusQuoted, AppColors.statusQuotedBg),
      OrderStatus.inProduction => ('Đang SX', AppColors.statusInProduction, AppColors.statusInProductionBg),
      OrderStatus.completed => ('Hoàn thành', AppColors.statusCompleted, AppColors.statusCompletedBg),
      OrderStatus.cancelled => ('Đã hủy', AppColors.errorRed, AppColors.errorRed.withValues(alpha: 0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─── Status Update BottomSheet ───────────────────────────────────────────────

void _showStatusUpdateSheet(
    BuildContext context, WidgetRef ref, Order order) {
  final noteController = TextEditingController();
  String? selectedStatus;

  final statuses = ['CONFIRMED', 'IN_PRODUCTION', 'COMPLETED', 'CANCELLED'];
  final statusLabels = {
    'CONFIRMED': 'Xác nhận đơn',
    'IN_PRODUCTION': 'Bắt đầu sản xuất',
    'COMPLETED': 'Hoàn thành',
    'CANCELLED': 'Hủy đơn',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
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
            Text('Cập nhật trạng thái — ${order.orderCode}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statuses.map((s) {
                final isSelected = selectedStatus == s;
                return ChoiceChip(
                  label: Text(statusLabels[s]!),
                  selected: isSelected,
                  selectedColor:
                      AppColors.primaryOrange.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (_) =>
                      setState(() => selectedStatus = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedStatus == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await ref
                            .read(staffActionsProvider.notifier)
                            .updateOrderStatus(
                              order.id,
                              selectedStatus!,
                              noteController.text.isEmpty
                                  ? null
                                  : noteController.text,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Đã cập nhật trạng thái đơn hàng')),
                          );
                        }
                      },
                child: const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
