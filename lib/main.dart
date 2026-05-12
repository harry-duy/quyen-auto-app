import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_flavor.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/widgets/connectivity_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppFlavor.init(Flavor.customer);

  await dotenv.load(fileName: '.env');

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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: ConnectivityBanner(child: child!),
        );
      },
    );
  }
}
