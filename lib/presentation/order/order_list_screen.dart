import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/order.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _kTabs = [
    (label: 'Đang xử lý', statuses: ['pending', 'confirmed', 'in_production']),
    (label: 'Hoàn thành', statuses: ['completed', 'cancelled']),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _kTabs.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.textGray,
          indicatorColor: AppColors.primaryOrange,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: _kTabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: ordersAsync.when(
        data: (allOrders) {
          return TabBarView(
            controller: _tabs,
            children: _kTabs.map((tab) {
              final filtered = allOrders.where((order) {
                final status = order.status.name == 'inProduction'
                    ? 'in_production'
                    : order.status.name;
                return tab.statuses.contains(status);
              }).toList();

              if (filtered.isEmpty) {
                return _EmptyOrders(
                  isProcessing: tab == _kTabs[0],
                  onOrder: () => context.go(AppRoutes.catalogue),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(orderListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.errorRed,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Không thể tải đơn hàng',
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(orderListProvider),
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

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final dateFmt = DateFormat('dd/MM/yyyy');
    final statusColor = AppColors.forOrderStatus(order.status.name);
    final statusBg = AppColors.bgForOrderStatus(order.status.name);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderOf(order.id)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  _StatusBadge(
                    label: _statusLabel(order.status),
                    color: statusColor,
                    backgroundColor: statusBg,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 15,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.productName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFmt.format(order.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.totalAmount > 0
                        ? fmt.format(order.totalAmount)
                        : 'Chờ báo giá',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Chờ xác nhận',
    OrderStatus.confirmed => 'Đã xác nhận',
    OrderStatus.inProduction => 'Đang sản xuất',
    OrderStatus.completed => 'Hoàn thành',
    OrderStatus.cancelled => 'Đã hủy',
  };
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onOrder;
  const _EmptyOrders({required this.isProcessing, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProcessing
                ? Icons.receipt_long_outlined
                : Icons.check_circle_outline,
            size: 72,
            color: AppColors.textGray.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isProcessing ? 'Không có đơn đang xử lý' : 'Chưa có đơn hoàn thành',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
          if (isProcessing) ...[
            const SizedBox(height: 8),
            const Text(
              'Hãy đặt hàng để bắt đầu.',
              style: TextStyle(fontSize: 13, color: AppColors.textGray),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: onOrder,
                child: const Text('Đặt hàng ngay'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
