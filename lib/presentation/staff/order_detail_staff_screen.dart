import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../domain/entities/order.dart';

class OrderDetailStaffScreen extends ConsumerWidget {
  final String id;
  const OrderDetailStaffScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(staffOrderDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: orderAsync.when(
        data: (order) => _OrderDetailBody(order: order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 48),
              const SizedBox(height: 8),
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(staffOrderDetailProvider(id)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerStatefulWidget {
  final Order order;
  const _OrderDetailBody({required this.order});

  @override
  ConsumerState<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends ConsumerState<_OrderDetailBody> {
  final _noteController = TextEditingController();
  String? _selectedStatus;
  bool _isUpdating = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final fmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    final (statusLabel, statusColor) = switch (order.status) {
      OrderStatus.pending         => ('Chờ xác nhận', AppColors.statusPending),
      OrderStatus.confirmed       => ('Đã xác nhận', AppColors.statusQuoted),
      OrderStatus.inProduction    => ('Đang sản xuất', AppColors.statusInProduction),
      OrderStatus.completed       => ('Hoàn thành', AppColors.statusCompleted),
      OrderStatus.cancelled       => ('Đã hủy', AppColors.errorRed),
      OrderStatus.cancelRequested => ('Chờ duyệt hủy', AppColors.warningAmber),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
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
                Expanded(
                  child: Text(order.orderCode,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor)),
                ),
              ]),
              const SizedBox(height: 12),
              _InfoRow(label: 'Sản phẩm', value: order.productName),
              _InfoRow(
                  label: 'Tổng tiền', value: fmt.format(order.totalAmount)),
              _InfoRow(
                  label: 'Ngày tạo', value: dateFmt.format(order.createdAt)),
              if (order.updatedAt != null)
                _InfoRow(
                    label: 'Dự kiến giao',
                    value: dateFmt.format(order.updatedAt!)),
              if (order.note != null)
                _InfoRow(label: 'Ghi chú', value: order.note!),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Cancel request approval section
        if (order.status == OrderStatus.cancelRequested) ...[
          const Text('Yêu cầu hủy đơn của khách hàng',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warningAmber)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khách hàng yêu cầu hủy đơn này. Bạn có muốn phê duyệt?',
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Ghi chú (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating ? null : () => _rejectCancel(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : () => _approveCancel(order.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isUpdating
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check),
                      label: const Text('Duyệt hủy'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Status update section (normal workflow)
        if (order.status != OrderStatus.completed &&
            order.status != OrderStatus.cancelled &&
            order.status != OrderStatus.cancelRequested) ...[
          const Text('Cập nhật trạng thái',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái mới',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'CONFIRMED', child: Text('Xác nhận đơn')),
                    DropdownMenuItem(
                        value: 'IN_PRODUCTION',
                        child: Text('Bắt đầu sản xuất')),
                    DropdownMenuItem(
                        value: 'COMPLETED', child: Text('Hoàn thành')),
                    DropdownMenuItem(
                        value: 'CANCELLED', child: Text('Hủy đơn')),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ghi chú kỹ thuật (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedStatus == null || _isUpdating ? null : _update,
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: const Text('Cập nhật'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _update() async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(staffActionsProvider.notifier).updateOrderStatus(
            widget.order.id,
            _selectedStatus!,
            _noteController.text.isEmpty ? null : _noteController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật trạng thái')),
        );
        _noteController.clear();
        setState(() {
          _selectedStatus = null;
          _isUpdating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _approveCancel(String orderId) async {
    setState(() => _isUpdating = true);
    try {
      final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
      await ref.read(staffActionsProvider.notifier).approveCancel(orderId, note: note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã duyệt hủy đơn hàng'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _noteController.clear();
        setState(() => _isUpdating = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  Future<void> _rejectCancel(String orderId) async {
    setState(() => _isUpdating = true);
    try {
      final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
      await ref.read(staffActionsProvider.notifier).rejectCancel(orderId, note: note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối yêu cầu hủy — đơn về trạng thái chờ xác nhận')),
        );
        _noteController.clear();
        setState(() => _isUpdating = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
