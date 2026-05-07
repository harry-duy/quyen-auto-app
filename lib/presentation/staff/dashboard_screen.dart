import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../core/router/staff_router.dart';
import '../../domain/entities/order.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(staffDashboardProvider);
    final ordersAsync = ref.watch(staffOrderListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryOrange,
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: AppColors.textWhite, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Staff Dashboard',
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ]),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(staffDashboardProvider);
          ref.invalidate(staffOrderListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Metric Cards
            dashboardAsync.when(
              data: (data) => _MetricCardsGrid(data: data),
              loading: () => const _MetricCardsGridShimmer(),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
            const SizedBox(height: 24),

            // Revenue Chart
            const Text('Doanh thu 6 tháng gần nhất',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            dashboardAsync.when(
              data: (data) => _RevenueChart(data: data),
              loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Recent pending orders
            const Text('Đơn hàng chờ xử lý',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            ordersAsync.when(
              data: (orders) {
                final pending = orders
                    .where((o) => o.status == OrderStatus.pending)
                    .take(5)
                    .toList();
                if (pending.isEmpty) {
                  return const _EmptyState(message: 'Không có đơn hàng chờ xử lý');
                }
                return Column(
                    children: pending.map((o) => _RecentOrderTile(order: o)).toList());
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorCard(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Metric Cards ────────────────────────────────────────────────────────────

class _MetricCardsGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MetricCardsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _MetricCard(
          title: 'Đơn mới',
          value: '${data['newOrders'] ?? 0}',
          icon: Icons.fiber_new,
          color: AppColors.infoBlue,
        ),
        _MetricCard(
          title: 'Đang sản xuất',
          value: '${data['inProduction'] ?? 0}',
          icon: Icons.precision_manufacturing,
          color: AppColors.primaryOrange,
        ),
        _MetricCard(
          title: 'Chờ báo giá',
          value: '${data['pendingQuotations'] ?? 0}',
          icon: Icons.request_quote,
          color: AppColors.warningAmber,
        ),
        _MetricCard(
          title: 'Bảo hành',
          value: '${data['activeWarranties'] ?? 0}',
          icon: Icons.build_circle,
          color: AppColors.successGreen,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray)),
        ],
      ),
    );
  }
}

class _MetricCardsGridShimmer extends StatelessWidget {
  const _MetricCardsGridShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Center(
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ),
    );
  }
}

// ─── Revenue BarChart ────────────────────────────────────────────────────────

class _RevenueChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final monthlyRevenue =
        (data['monthlyRevenue'] as List<dynamic>?) ?? [];

    if (monthlyRevenue.isEmpty) {
      return const _EmptyState(message: 'Chưa có dữ liệu doanh thu');
    }

    final bars = <BarChartGroupData>[];
    final labels = <String>[];

    for (var i = 0; i < monthlyRevenue.length && i < 6; i++) {
      final item = monthlyRevenue[i] as Map<String, dynamic>;
      final revenue = (item['revenue'] as num?)?.toDouble() ?? 0;
      final month = item['month']?.toString() ?? 'T${i + 1}';

      bars.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue / 1000000,
            color: AppColors.primaryOrange,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ));
      labels.add(month);
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: bars
                  .map((b) => b.barRods.first.toY)
                  .fold<double>(0, (a, b) => a > b ? a : b) *
              1.3,
          barGroups: bars,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}tr',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textGray),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(labels[idx],
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGray));
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final fmt = NumberFormat.currency(
                    locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
                return BarTooltipItem(
                  fmt.format(rod.toY * 1000000),
                  const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Recent Order Tile ───────────────────────────────────────────────────────

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed(StaffRoutes.orderOf(order.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.pending_actions,
                color: AppColors.warningAmber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderCode,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(order.productName,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(order.totalAmount),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange)),
              const SizedBox(height: 2),
              Text(dateFmt.format(order.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGray)),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined,
                color: AppColors.textGray, size: 40),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textGray)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.errorRed)),
        ),
      ]),
    );
  }
}
