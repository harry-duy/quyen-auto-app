import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/notification/notification_screen.dart';
import '../../presentation/order/order_detail_screen.dart';
import '../../presentation/order/quotation_form_screen.dart';
import '../../presentation/product/product_detail_screen.dart';
import '../../presentation/staff/dealer_map_screen.dart';
import '../../presentation/staff/department_management_screen.dart';
import '../../presentation/staff/order_detail_staff_screen.dart';
import '../../presentation/staff/staff_home_screen.dart';
import '../../presentation/staff/staff_member_management_screen.dart';
import '../../presentation/warranty/add_vehicle_screen.dart';
import '../di/providers.dart';
import '../../domain/entities/user.dart';
import 'route_paths.dart';

export 'route_paths.dart';

// --- Router provider ---------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  String homeFor(UserRole role) =>
      role.isStaffOrAbove ? StaffRoutes.home : AppRoutes.home;

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    debugLogDiagnostics: true,

    // Auth guard
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final loc = state.matchedLocation;
      final onAuthScreen = loc == AppRoutes.login || loc == AppRoutes.register;
      final onStaffScreen = loc.startsWith('/staff');

      if (!isLoggedIn && !onAuthScreen) return AppRoutes.login;
      if (!isLoggedIn) return null;

      final targetHome = homeFor(user.role);
      if (onAuthScreen) return targetHome;
      if (user.role.isStaffOrAbove && !onStaffScreen) return targetHome;
      if (!user.role.isStaffOrAbove && onStaffScreen) return AppRoutes.home;
      return null;
    },

    routes: [
      // Auth
      GoRoute(path: AppRoutes.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),

      // Customer shell (HomeScreen handles BottomNav + IndexedStack internally)
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),

      // Customer pages
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (_, s) => ProductDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (_, s) => OrderDetailScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.quotation,
        builder: (_, s) => QuotationFormScreen(
          preselectedProductId: s.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (_, s) => ChatScreen(roomId: s.pathParameters['roomId']!),
      ),
      GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationScreen()),
      GoRoute(path: AppRoutes.addVehicle,    builder: (_, __) => const AddVehicleScreen()),

      // Staff shell and pages
      GoRoute(path: StaffRoutes.home, builder: (_, __) => const StaffHomeScreen()),
      GoRoute(
        path: StaffRoutes.orderDetail,
        builder: (_, s) => OrderDetailStaffScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: StaffRoutes.chat,
        builder: (_, s) => ChatScreen(roomId: s.pathParameters['roomId']!),
      ),
      GoRoute(path: StaffRoutes.dealerMap, builder: (_, __) => const DealerMapScreen()),
      GoRoute(path: StaffRoutes.departments, builder: (_, __) => const DepartmentManagementScreen()),
      GoRoute(path: StaffRoutes.staffMembers, builder: (_, __) => const StaffMemberManagementScreen()),
    ],
  );
});
