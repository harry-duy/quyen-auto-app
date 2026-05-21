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
import '../../presentation/warranty/add_vehicle_screen.dart';
import '../di/providers.dart';

// --- Route constants ---------------------------------------------------------

abstract final class AppRoutes {
  static const login         = '/login';
  static const register      = '/register';
  static const home          = '/home';
  static const catalogue     = '/home/catalogue';   // handled via tab switch
  static const orders        = '/home/orders';      // handled via tab switch
  static const warranty      = '/home/warranty';    // handled via tab switch
  static const profile       = '/home/profile';     // handled via tab switch
  static const productDetail = '/product/:id';
  static const orderDetail   = '/order/:id';
  static const quotation     = '/quotation-form';
  static const chat          = '/chat/:roomId';
  static const notifications = '/notifications';
  static const addVehicle    = '/vehicle/add';

  static String productOf(String id)   => '/product/$id';
  static String orderOf(String id)     => '/order/$id';
  static String chatOf(String roomId)  => '/chat/$roomId';
}

// --- Router provider ---------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    debugLogDiagnostics: true,

    // Auth guard — public routes accessible without login
    redirect: (context, state) {
      final isLoggedIn   = ref.read(isAuthenticatedProvider);
      final loc          = state.matchedLocation;
      final onAuthScreen = loc == AppRoutes.login || loc == AppRoutes.register;

      // Already logged in → skip auth screens
      if (isLoggedIn && onAuthScreen) return AppRoutes.home;

      // Routes that require login
      final needsAuth = loc.startsWith('/order/') ||
          loc.startsWith('/chat/') ||
          loc == AppRoutes.notifications ||
          loc == AppRoutes.addVehicle;

      if (!isLoggedIn && needsAuth) return AppRoutes.login;
      return null;
    },

    routes: [
      // Auth
      GoRoute(path: AppRoutes.login,    builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),

      // Main shell (HomeScreen handles BottomNav + IndexedStack internally)
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),

      // Full-screen overlay pages (pushed on top of the shell)
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
      GoRoute(path: AppRoutes.notifications, builder: (_, _) => const NotificationScreen()),
      GoRoute(path: AppRoutes.addVehicle,    builder: (_, _) => const AddVehicleScreen()),
    ],
  );
});
