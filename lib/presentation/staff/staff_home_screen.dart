import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import 'dashboard_screen.dart';
import 'order_management_screen.dart';
import 'quotation_list_staff_screen.dart';
import 'warranty_management_screen.dart';
import 'staff_chat_list_screen.dart';
import 'staff_profile_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(staffTabIndexProvider);
    final uncontactedAsync = ref.watch(staffUncontactedCountProvider);

    void switchTab(int i) =>
        ref.read(staffTabIndexProvider.notifier).state = i;

    const tabs = <Widget>[
      StaffDashboardScreen(),
      OrderManagementScreen(),
      QuotationListStaffScreen(),
      WarrantyManagementScreen(),
      StaffChatListScreen(),
      StaffProfileScreen(),
    ];

    final uncontactedCount = uncontactedAsync.valueOrNull ?? 0;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: switchTab,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 16,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: _BadgeIcon(
              icon: Icons.request_quote_outlined,
              count: uncontactedCount,
            ),
            activeIcon: _BadgeIcon(
              icon: Icons.request_quote,
              count: uncontactedCount,
              active: true,
            ),
            label: 'Báo giá',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Bảo hành',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;

  const _BadgeIcon({
    required this.icon,
    required this.count,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon,
            color: active ? AppColors.primaryOrange : AppColors.textGray),
        if (count > 0)
          Positioned(
            top: -4,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.errorRed,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
