import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'token_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  final ApiService _api;
  final TokenService _tokenService;
  final Logger _log = Logger();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  void Function(RemoteMessage)? onMessageReceived;

  PushNotificationService(this._api, this._tokenService);

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      _log.w('Firebase init skipped (may already be initialized): $e');
    }

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      _log.i('FCM foreground: ${message.notification?.title}');
      onMessageReceived?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log.i('FCM opened app: ${message.data}');
      onMessageReceived?.call(message);
    });

    await _registerToken();

    _fcm.onTokenRefresh.listen((newToken) async {
      await _sendTokenToServer(newToken);
    });
  }

  Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (e) {
      _log.e('Failed to get FCM token: $e');
    }
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    final isLoggedIn = await _tokenService.isLoggedIn();
    if (!isLoggedIn) return;

    try {
      await _api.post(
        ApiConstants.fcmToken,
        data: {
          'token': fcmToken,
          'deviceType': 'ANDROID',
        },
      );
      _log.i('FCM token registered with server');
    } catch (e) {
      _log.e('Failed to register FCM token: $e');
    }
  }

  Future<void> removeToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _api.delete('${ApiConstants.fcmToken}/$token');
      }
    } catch (e) {
      _log.e('Failed to remove FCM token: $e');
    }
  }
}
