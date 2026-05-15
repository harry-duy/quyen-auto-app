import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/staff/staff_home_screen.dart';
import '../../presentation/staff/order_detail_staff_screen.dart';
import '../../presentation/staff/dealer_map_screen.dart';
import '../../presentation/staff/department_management_screen.dart';
import '../../presentation/staff/create_customer_screen.dart';
import '../../presentation/staff/staff_member_management_screen.dart';
import '../di/providers.dart';

abstract final class StaffRoutes {
  static const login          = '/login';
  static const register       = '/register';
  static const home           = '/home';
  static const orderDetail    = '/order/:id';
  static const chat           = '/chat/:roomId';
  static const dealerMap      = '/dealers/map';
  static const departments    = '/management/departments';
  static const staffMembers   = '/management/staff';
  static const createCustomer = '/customers/create';

  static String orderOf(String id)    => '/order/$id';
  static String chatOf(String roomId) => '/chat/$roomId';
}

final staffRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: StaffRoutes.home,
    refreshListenable: notifier,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final isLoggedIn   = ref.read(isAuthenticatedProvider);
      final loc          = state.matchedLocation;
      final onAuthScreen = loc == StaffRoutes.login || loc == StaffRoutes.register;

      if (!isLoggedIn && !onAuthScreen) return StaffRoutes.login;
      if (isLoggedIn  && onAuthScreen)  return StaffRoutes.home;
      return null;
    },

    routes: [
      GoRoute(path: StaffRoutes.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: StaffRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: StaffRoutes.home,     builder: (_, __) => const StaffHomeScreen()),
      GoRoute(
        path: StaffRoutes.orderDetail,
        builder: (_, s) => OrderDetailStaffScreen(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: StaffRoutes.chat,
        builder: (_, s) => ChatScreen(roomId: s.pathParameters['roomId']!),
      ),
      GoRoute(path: StaffRoutes.dealerMap,       builder: (_, __) => const DealerMapScreen()),
      GoRoute(path: StaffRoutes.departments,   builder: (_, __) => const DepartmentManagementScreen()),
      GoRoute(path: StaffRoutes.staffMembers,  builder: (_, __) => const StaffMemberManagementScreen()),
      GoRoute(path: StaffRoutes.createCustomer, builder: (_, __) => const CreateCustomerScreen()),
    ],
  );
});
