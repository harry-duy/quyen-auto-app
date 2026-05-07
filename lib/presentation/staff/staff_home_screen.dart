import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import 'dashboard_screen.dart';
import 'order_management_screen.dart';
import 'warranty_management_screen.dart';
import 'staff_chat_list_screen.dart';
import 'staff_profile_screen.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(staffTabIndexProvider);

    void switchTab(int i) =>
        ref.read(staffTabIndexProvider.notifier).state = i;

    const tabs = <Widget>[
      StaffDashboardScreen(),
      OrderManagementScreen(),
      WarrantyManagementScreen(),
      StaffChatListScreen(),
      StaffProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: switchTab,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 16,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Bảo hành',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
