import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import 'dashboard_screen.dart';
import 'management_hub_screen.dart';
import 'order_management_screen.dart';
import 'quotation_list_staff_screen.dart';
import 'staff_chat_list_screen.dart';
import 'staff_profile_screen.dart';
import 'warranty_management_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(staffTabIndexProvider);
    final uncontactedAsync = ref.watch(staffUncontactedCountProvider);
    final user = ref.watch(authProvider).valueOrNull;

    final isManager = user?.role.isManagerOrAbove ?? false;
    final uncontactedCount = uncontactedAsync.valueOrNull ?? 0;

    void switchTab(int i) =>
        ref.read(staffTabIndexProvider.notifier).state = i;

    // Tabs và nav items được xây động dựa trên role:
    // STAFF      → 6 tabs: Dashboard / Orders / Quotations / Warranty / Chat / Profile
    // MANAGER+   → 7 tabs: Dashboard / Orders / Quotations / Warranty / Chat / Management / Profile
    final tabs = <Widget>[
      const StaffDashboardScreen(),
      const OrderManagementScreen(),
      const QuotationListStaffScreen(),
      const WarrantyManagementScreen(),
      const StaffChatListScreen(),
      if (isManager) const ManagementHubScreen(),
      const StaffProfileScreen(),
    ];

    final safeIndex = currentIndex.clamp(0, tabs.length - 1);
    if (safeIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ref.read(staffTabIndexProvider.notifier).state = safeIndex);
    }

    final navItems = <BottomNavigationBarItem>[
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
        icon: _BadgeIcon(icon: Icons.request_quote_outlined, count: uncontactedCount),
        activeIcon: _BadgeIcon(icon: Icons.request_quote, count: uncontactedCount, active: true),
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
      if (isManager)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Quản lý',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Tài khoản',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: switchTab,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 16,
        items: navItems,
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
