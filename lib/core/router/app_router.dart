import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/chat/customer_chat_list_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/notification/notification_screen.dart';
import '../../presentation/order/order_detail_screen.dart';
import '../../presentation/order/payment_screen.dart';
import '../../presentation/order/quotation_form_screen.dart';
import '../../presentation/product/product_detail_screen.dart';
import '../../presentation/staff/create_customer_screen.dart';
import '../../presentation/warranty/add_vehicle_screen.dart';
import '../../presentation/warranty/vehicle_list_screen.dart';
import '../di/providers.dart';
import '../../domain/entities/user.dart';
import 'route_paths.dart';

// --- Route constants ---------------------------------------------------------

abstract final class AppRoutes {
  static const login         = '/login';
  static const register      = '/register';
  static const verifyOtp     = '/verify-otp';
  static const home          = '/home';
  static const catalogue     = '/home/catalogue';
  static const orders        = '/home/orders';
  static const warranty      = '/home/warranty';
  static const profile       = '/home/profile';
  static const productDetail = '/product/:id';
  static const orderDetail   = '/order/:id';
  static const quotation     = '/quotation-form';
  static const chat          = '/chat/:roomId';
  static const chatList      = '/chat-list';
  static const notifications = '/notifications';
  static const addVehicle    = '/vehicle/add';
  static const vehicleList   = '/vehicle-list';
  static const createCustomer = '/staff/create-customer';
  static const payment        = '/payment';

  static String productOf(String id)   => '/product/$id';
  static String orderOf(String id)     => '/order/$id';
  static String chatOf(String roomId)  => '/chat/$roomId';
}

// --- Pages that require login ------------------------------------------------

const _authRequiredPaths = {
  '/order/',
  '/chat/',
  '/notifications',
  '/vehicle/',
  '/home/orders',
  '/home/warranty',
  '/home/profile',
  '/staff/',
};

// --- Router provider ---------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  String homeFor(UserRole role) =>
      role.isStaffOrAbove ? StaffRoutes.home : AppRoutes.home;

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final isLoggedIn = ref.read(isAuthenticatedProvider);
      final loc        = state.matchedLocation;

      if (loc == AppRoutes.login && isLoggedIn) return AppRoutes.home;

      final needsAuth = _authRequiredPaths.any((p) => loc.startsWith(p));
      if (needsAuth && !isLoggedIn) return AppRoutes.login;

      return null;
    },

    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),

      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),


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
      GoRoute(path: AppRoutes.register,       builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.verifyOtp,      redirect: (_, __) => AppRoutes.home),
      GoRoute(path: AppRoutes.chatList,       builder: (_, __) => const CustomerChatListScreen()),
      GoRoute(path: AppRoutes.notifications,  builder: (_, __) => const NotificationScreen()),
      GoRoute(path: AppRoutes.addVehicle,     builder: (_, __) => const AddVehicleScreen()),
      GoRoute(path: AppRoutes.vehicleList,    builder: (_, __) => const VehicleListScreen()),
      GoRoute(path: AppRoutes.createCustomer, builder: (_, __) => const CreateCustomerScreen()),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, s) {
          final args = s.extra as Map<String, String>;
          return PaymentScreen(
            paymentUrl: args['paymentUrl']!,
            orderCode: args['orderCode']!,
          );
        },
      ),
    ],
  );
});
