import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/order.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(id));

    ref.listen(orderStatusStreamProvider(id), (_, next) {
      next.whenData((newStatus) {
        if (newStatus != null) {
          ref.invalidate(orderDetailProvider(id));
          ref.invalidate(orderListProvider);
        }
      });
    });

    return orderAsync.when(
      data: (order) => _OrderDetailView(order: order),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text('Không thể tải đơn hàng'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(orderDetailProvider(id)),
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

class _OrderDetailView extends ConsumerWidget {
  final Order order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('HH:mm - dd/MM/yyyy');
    final dayFmt = DateFormat('dd/MM/yyyy');
    final statusColor = AppColors.forOrderStatus(order.status.name);
    final statusBg = AppColors.bgForOrderStatus(order.status.name);
    final canCancel = order.status == OrderStatus.pending;
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
            tooltip: 'Sao chép mã đơn',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.orderCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép mã đơn hàng')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(order.status), color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái đơn hàng',
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        _statusLabel(order.status),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _StatusTimeline(
              current: order.status,
              productionStatus: order.productionStatus,
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Thông tin đơn hàng',
              rows: [
                ('Mã đơn', order.orderCode),
                ('Sản phẩm', order.productName),
                ('Ngày tạo', dateFmt.format(order.createdAt)),
                if (order.updatedAt != null)
                  ('Cập nhật', dateFmt.format(order.updatedAt!)),
                if (order.estimatedDate != null)
                  ('Dự kiến hoàn thành', dayFmt.format(order.estimatedDate!)),
                if (order.assignedStaffName?.isNotEmpty == true)
                  ('Nhân viên phụ trách', order.assignedStaffName!),
                if (order.note != null && order.note!.isNotEmpty)
                  ('Ghi chú', order.note!),
              ],
            ),
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
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thành tiền',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                      Text(
                        order.totalAmount > 0
                            ? fmt.format(order.totalAmount)
                            : 'Chờ báo giá',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  if (order.depositAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Đã cọc',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                        Text(
                          fmt.format(order.depositAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Còn lại',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                        Text(
                          fmt.format(remaining),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startChat(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Liên hệ'),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      minimumSize: const Size(0, 52),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Hủy đơn'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startChat(BuildContext context, WidgetRef ref) async {
    try {
      final statusLabels = {
        'pending': 'Chờ xác nhận',
        'confirmed': 'Đã xác nhận',
        'inProduction': 'Đang sản xuất',
        'inproduction': 'Đang sản xuất',
        'completed': 'Hoàn thành',
        'cancelled': 'Đã hủy',
      };
      final statusLabel = statusLabels[order.status.name] ?? order.status.name;
      final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
      final summary =
          'Đơn hàng: ${order.orderCode}\n'
          'Sản phẩm: ${order.productName}\n'
          'Tổng tiền: ${order.totalAmount > 0 ? fmt.format(order.totalAmount) : "Chờ báo giá"}\n'
          'Trạng thái: $statusLabel\n\n'
          'Tôi cần hỗ trợ về đơn hàng này.';

      final room = await ref
          .read(chatActionsProvider.notifier)
          .startChat(orderCode: order.orderCode, firstMessage: summary);
      if (context.mounted) {
        context.push(AppRoutes.chatOf(room.id.toString()));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở chat: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: Text('Bạn có chắc muốn hủy đơn hàng ${order.orderCode}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(OrderStatus s) => switch (s) {
    OrderStatus.pending => Icons.schedule,
    OrderStatus.confirmed => Icons.thumb_up_outlined,
    OrderStatus.inProduction => Icons.precision_manufacturing_outlined,
    OrderStatus.completed => Icons.check_circle_outline,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };

  String _statusLabel(OrderStatus s) => switch (s) {
    OrderStatus.pending => 'Chờ xác nhận',
    OrderStatus.confirmed => 'Đã xác nhận',
    OrderStatus.inProduction => 'Đang sản xuất',
    OrderStatus.completed => 'Hoàn thành',
    OrderStatus.cancelled => 'Đã hủy',
  };
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
                    width: 90,
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

class _StatusTimeline extends StatelessWidget {
  final OrderStatus current;
  final String productionStatus;
  const _StatusTimeline({
    required this.current,
    required this.productionStatus,
  });

  static const _steps = [
    (code: 'RECEIVED', label: 'Tiếp nhận yêu cầu', icon: Icons.inbox_outlined),
    (
      code: 'INFO_CONFIRMED',
      label: 'Xác nhận thông tin',
      icon: Icons.fact_check_outlined,
    ),
    (
      code: 'QUOTED_DEPOSITED',
      label: 'Báo giá & đặt cọc',
      icon: Icons.request_quote_outlined,
    ),
    (
      code: 'ORDER_CONFIRMED',
      label: 'Xác nhận đơn hàng',
      icon: Icons.thumb_up_outlined,
    ),
    (
      code: 'PRODUCTION_STARTED',
      label: 'Bắt đầu sản xuất',
      icon: Icons.precision_manufacturing_outlined,
    ),
    (
      code: 'QUALITY_CHECKING',
      label: 'Kiểm tra chất lượng',
      icon: Icons.verified_outlined,
    ),
    (code: 'COMPLETED', label: 'Hoàn thành', icon: Icons.check_circle_outline),
  ];

  int get _currentStepIndex {
    final normalized = _normalizeProductionStatus(productionStatus, current);
    final index = _steps.indexWhere((step) => step.code == normalized);
    return index < 0 ? 0 : index;
  }

  _StepState _stepState(int index) {
    if (index < _currentStepIndex) return _StepState.done;
    if (index == _currentStepIndex) return _StepState.current;
    return _StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    if (current == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.errorRed),
            SizedBox(width: 12),
            Text(
              'Đơn hàng đã bị hủy',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến trình đơn hàng',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ..._steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return _TimelineStep(
              icon: step.icon,
              label: step.label,
              state: _stepState(i),
              isLast: i == _steps.length - 1,
            );
          }),
        ],
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
    'QUALITY_CHECKING' || 'DELIVERING' => 'QUALITY_CHECKING',
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

enum _StepState { done, current, upcoming }

class _TimelineStep extends StatefulWidget {
  final IconData icon;
  final String label;
  final _StepState state;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.state,
    required this.isLast,
  });

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.state == _StepState.current) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color iconColor;
    final Color textColor;
    final FontWeight textWeight;

    switch (widget.state) {
      case _StepState.done:
        circleColor = AppColors.successGreen;
        iconColor = AppColors.textWhite;
        textColor = AppColors.successGreen;
        textWeight = FontWeight.w500;
      case _StepState.current:
        circleColor = AppColors.primaryOrange;
        iconColor = AppColors.textWhite;
        textColor = AppColors.primaryOrange;
        textWeight = FontWeight.w700;
      case _StepState.upcoming:
        circleColor = AppColors.borderLight;
        iconColor = AppColors.textGray;
        textColor = AppColors.textGray.withValues(alpha: 0.5);
        textWeight = FontWeight.w400;
    }

    final lineColor = widget.state == _StepState.done
        ? AppColors.successGreen.withValues(alpha: 0.4)
        : AppColors.borderLight;

    Widget circleWidget = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.state == _StepState.upcoming
            ? Colors.transparent
            : circleColor,
        border: widget.state == _StepState.upcoming
            ? Border.all(color: AppColors.borderLight, width: 2)
            : null,
      ),
      child: Icon(
        widget.state == _StepState.done ? Icons.check : widget.icon,
        size: 15,
        color: iconColor,
      ),
    );

    if (widget.state == _StepState.current && _pulseController != null) {
      circleWidget = AnimatedBuilder(
        animation: _pulseController!,
        builder: (_, child) {
          final scale = 1.0 + _pulseController!.value * 0.15;
          return Transform.scale(scale: scale, child: child);
        },
        child: circleWidget,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                circleWidget,
                if (!widget.isLast)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 22),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: textWeight,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
