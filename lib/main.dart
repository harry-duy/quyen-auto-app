import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_flavor.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppFlavor.init(Flavor.customer);

  await dotenv.load(fileName: '.env');

  // Khoi tao Firebase — bo qua neu chua co google-services.json / firebase_options.dart
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase chua duoc cau hinh — FCM se bi vo hieu hoa tu dong
  }

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>('auth'),
    Hive.openBox<String>('cache'),
  ]);

  runApp(const ProviderScope(child: QuyenAutoApp()));
}

class QuyenAutoApp extends ConsumerWidget {
  const QuyenAutoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Quyen Auto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        // Giới hạn font scale tránh UI bị vỡ trên thiết bị tăng cỡ chữ
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
