import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return orderAsync.when(
      data: (order) => _OrderDetailBody(order: order),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi ti?t don h�ng')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi ti?t don h�ng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: AppColors.errorRed),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(staffOrderDetailProvider(id)),
                icon: const Icon(Icons.refresh),
                label: const Text('Th? l?i'),
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
      locale: 'vi_VN',
      symbol: '?',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('HH:mm - dd/MM/yyyy');
    final dayFmt = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(order.status);
    final statusBg = _statusBg(order.status);
    final remaining = (order.totalAmount - order.depositAmount).clamp(
      0,
      double.infinity,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(order.orderCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Sao ch�p m� don',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.orderCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('�� sao ch�p m� don h�ng')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusBanner(
            status: order.status,
            color: statusColor,
            backgroundColor: statusBg,
          ),
          const SizedBox(height: 16),
          _StatusTimeline(
            current: order.status,
            productionStatus: order.productionStatus,
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Th�ng tin don h�ng',
            rows: [
              ('M� don', order.orderCode),
              ('S?n ph?m', order.productName),
              if (order.customerName?.isNotEmpty == true)
                ('Kh�ch h�ng', order.customerName!),
              if (order.customerPhone?.isNotEmpty == true)
                ('S? di?n tho?i', order.customerPhone!),
              ('Ng�y t?o', dateFmt.format(order.createdAt)),
              if (order.updatedAt != null)
                ('C?p nh?t', dateFmt.format(order.updatedAt!)),
              if (order.estimatedDate != null)
                ('D? ki?n giao', dayFmt.format(order.estimatedDate!)),
              if (order.assignedStaffName?.isNotEmpty == true)
                ('Nh�n vi�n ph? tr�ch', order.assignedStaffName!),
              if (order.productionStatus.isNotEmpty)
                (
                  'Tr?ng th�i s?n xu?t',
                  _productionLabel(order.productionStatus),
                ),
              if (order.note?.isNotEmpty == true) ('Ghi ch�', order.note!),
            ],
          ),
          const SizedBox(height: 12),
          _AmountCard(
            total: order.totalAmount,
            deposit: order.depositAmount,
            remaining: remaining.toDouble(),
            formatter: fmt,
          ),
          const SizedBox(height: 20),
          if (order.status != OrderStatus.completed &&
              order.status != OrderStatus.cancelled)
            _StatusUpdateCard(
              selectedStatus: _selectedStatus,
              noteController: _noteController,
              isUpdating: _isUpdating,
              onStatusChanged: (v) => setState(() => _selectedStatus = v),
              onUpdate: _update,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _update() async {
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .updateOrderStatus(
            widget.order.id,
            _selectedStatus!,
            _noteController.text.isEmpty ? null : _noteController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('�� c?p nh?t tr?ng th�i')));
      _noteController.clear();
      setState(() {
        _selectedStatus = null;
        _isUpdating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('L?i: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }
}

class _StatusBanner extends StatelessWidget {
  final OrderStatus status;
  final Color color;
  final Color backgroundColor;

  const _StatusBanner({
    required this.status,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(status), color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tr?ng th�i don h�ng',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              Text(
                _statusLabel(status),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 20),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      r.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final double total;
  final double deposit;
  final double remaining;
  final NumberFormat formatter;

  const _AmountCard({
    required this.total,
    required this.deposit,
    required this.remaining,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thanh to�n',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 20),
          _MoneyRow(label: 'T?ng gi� tr?', value: formatter.format(total)),
          if (deposit > 0)
            _MoneyRow(label: '�� c?c', value: formatter.format(deposit)),
          if (deposit > 0)
            _MoneyRow(label: 'C�n l?i', value: formatter.format(remaining)),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final String value;
  const _MoneyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGray)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusUpdateCard extends StatelessWidget {
  final String? selectedStatus;
  final TextEditingController noteController;
  final bool isUpdating;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onUpdate;

  const _StatusUpdateCard({
    required this.selectedStatus,
    required this.noteController,
    required this.isUpdating,
    required this.onStatusChanged,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'C?p nh?t tr?ng th�i',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Tr?ng th�i m?i',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<String>(
                value: 'RECEIVED',
                child: Text('Ti?p nh?n y�u c?u'),
              ),
              DropdownMenuItem<String>(
                value: 'INFO_CONFIRMED',
                child: Text('X�c nh?n th�ng tin'),
              ),
              DropdownMenuItem<String>(
                value: 'QUOTED_DEPOSITED',
                child: Text('B�o gi� & d?t c?c'),
              ),
              DropdownMenuItem<String>(
                value: 'ORDER_CONFIRMED',
                child: Text('X�c nh?n don h�ng'),
              ),
              DropdownMenuItem<String>(
                value: 'PRODUCTION_STARTED',
                child: Text('B?t d?u s?n xu?t'),
              ),
              DropdownMenuItem<String>(
                value: 'QUALITY_CHECKING',
                child: Text('Ki?m tra ch?t lu?ng'),
              ),
              DropdownMenuItem<String>(
                value: 'COMPLETED',
                child: Text('Ho�n th�nh'),
              ),
              DropdownMenuItem<String>(
                value: 'CANCELLED',
                child: Text('�� h?y'),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ghi ch� k? thu?t (t�y ch?n)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedStatus == null || isUpdating ? null : onUpdate,
              icon: isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('C?p nh?t'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus current;
  final String productionStatus;
  const _StatusTimeline({
    required this.current,
    required this.productionStatus,
  });

  static const _steps = [
    (code: 'RECEIVED', label: 'Ti?p nh?n y�u c?u', icon: Icons.inbox_outlined),
    (
      code: 'INFO_CONFIRMED',
      label: 'X�c nh?n th�ng tin',
      icon: Icons.fact_check_outlined,
    ),
    (
      code: 'QUOTED_DEPOSITED',
      label: 'B�o gi� & d?t c?c',
      icon: Icons.request_quote_outlined,
    ),
    (
      code: 'ORDER_CONFIRMED',
      label: 'X�c nh?n don h�ng',
      icon: Icons.thumb_up_outlined,
    ),
    (
      code: 'PRODUCTION_STARTED',
      label: 'B?t d?u s?n xu?t',
      icon: Icons.precision_manufacturing_outlined,
    ),
    (
      code: 'QUALITY_CHECKING',
      label: 'Ki?m tra ch?t lu?ng',
      icon: Icons.verified_outlined,
    ),
    (code: 'COMPLETED', label: 'Ho�n th�nh', icon: Icons.check_circle_outline),
  ];

  int get _currentStepIndex {
    final normalized = _normalizeProductionStatus(productionStatus, current);
    final index = _steps.indexWhere((step) => step.code == normalized);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    if (current == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.errorRed),
            SizedBox(width: 10),
            Expanded(child: Text('�on h�ng d� b? h?y')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final done = index <= _currentStepIndex;
          final isLast = index == _steps.length - 1;
          final color = done ? AppColors.primaryOrange : AppColors.textGray;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.primaryOrange.withValues(alpha: 0.12)
                          : AppColors.statusPendingBg,
                    ),
                    child: Icon(step.icon, size: 16, color: color),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 28,
                      color: done
                          ? AppColors.primaryOrange.withValues(alpha: 0.5)
                          : AppColors.borderLight,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    step.label,
                    style: TextStyle(
                      color: done ? AppColors.textDark : AppColors.textGray,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

String _normalizeProductionStatus(String status, OrderStatus orderStatus) {
  final normalized = status.toUpperCase();
  return switch (normalized) {
    'RECEIVED' => 'RECEIVED',
    'INFO_CONFIRMED' => 'INFO_CONFIRMED',
    'QUOTED_DEPOSITED' => 'QUOTED_DEPOSITED',
    'ORDER_CONFIRMED' || 'NOT_STARTED' => 'ORDER_CONFIRMED',
    'PRODUCTION_STARTED' || 'IN_PROGRESS' => 'PRODUCTION_STARTED',
    'QUALITY_CHECKING' => 'QUALITY_CHECKING',
    'DELIVERING' => 'QUALITY_CHECKING',
    'COMPLETED' => 'COMPLETED',
    'CANCELLED' => 'CANCELLED',
    _ => switch (orderStatus) {
      OrderStatus.pending => 'RECEIVED',
      OrderStatus.confirmed => 'ORDER_CONFIRMED',
      OrderStatus.inProduction => 'PRODUCTION_STARTED',
      OrderStatus.completed => 'COMPLETED',
      OrderStatus.cancelled => 'CANCELLED',
    },
  };
}

IconData _statusIcon(OrderStatus s) => switch (s) {
  OrderStatus.pending => Icons.schedule,
  OrderStatus.confirmed => Icons.thumb_up_outlined,
  OrderStatus.inProduction => Icons.precision_manufacturing_outlined,
  OrderStatus.completed => Icons.check_circle_outline,
  OrderStatus.cancelled => Icons.cancel_outlined,
};

String _statusLabel(OrderStatus s) => switch (s) {
  OrderStatus.pending => 'Ch? x�c nh?n',
  OrderStatus.confirmed => '�� x�c nh?n',
  OrderStatus.inProduction => '�ang s?n xu?t',
  OrderStatus.completed => 'Ho�n th�nh',
  OrderStatus.cancelled => '�� h?y',
};

Color _statusColor(OrderStatus s) => switch (s) {
  OrderStatus.pending => AppColors.statusPending,
  OrderStatus.confirmed => AppColors.statusQuoted,
  OrderStatus.inProduction => AppColors.statusInProduction,
  OrderStatus.completed => AppColors.statusCompleted,
  OrderStatus.cancelled => AppColors.errorRed,
};

Color _statusBg(OrderStatus s) => switch (s) {
  OrderStatus.pending => AppColors.statusPendingBg,
  OrderStatus.confirmed => AppColors.statusQuotedBg,
  OrderStatus.inProduction => AppColors.statusInProductionBg,
  OrderStatus.completed => AppColors.statusCompletedBg,
  OrderStatus.cancelled => AppColors.errorRed.withValues(alpha: 0.08),
};

String _productionLabel(String status) => switch (status.toUpperCase()) {
  'RECEIVED' => 'Ti?p nh?n y�u c?u',
  'INFO_CONFIRMED' => 'X�c nh?n th�ng tin',
  'QUOTED_DEPOSITED' => 'B�o gi� & d?t c?c',
  'ORDER_CONFIRMED' || 'NOT_STARTED' => 'X�c nh?n don h�ng',
  'PRODUCTION_STARTED' || 'IN_PROGRESS' => 'B?t d?u s?n xu?t',
  'QUALITY_CHECKING' => 'Ki?m tra ch?t lu?ng',
  'COMPLETED' => '�� ho�n th�nh',
  'CANCELLED' => '�� h?y',
  _ => status,
};
