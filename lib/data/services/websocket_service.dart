import 'dart:async';

import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/constants/api_constants.dart';

typedef MessageCallback = void Function(String body);

class WebSocketService {
  StompClient? _client;
  final Logger _log = Logger();
  final Map<String, StompUnsubscribe> _subscriptions = {};
  Completer<void>? _connectCompleter;
  int _errorCount = 0;

  bool get isConnected => _client != null && _connectCompleter?.isCompleted == true;

  Future<void> connect({required String token}) async {
    if (isConnected) return;

    _connectCompleter = Completer<void>();
    _errorCount = 0;

    _client = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (frame) {
          _log.i('WebSocket connected');
          _errorCount = 0;
          if (!_connectCompleter!.isCompleted) {
            _connectCompleter!.complete();
          }
        },
        onWebSocketError: (err) {
          // Only log the first error to avoid console spam when backend is offline
          if (_errorCount == 0) {
            _log.w('WS offline (will retry every 30s): $err');
          }
          _errorCount++;
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.completeError(err);
          }
        },
        onStompError: (frame) => _log.w('STOMP Error: ${frame.body}'),
        onDisconnect: (_) {
          _log.w('WebSocket disconnected');
          _subscriptions.clear();
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 30),
      ),
    );
    _client!.activate();

    return _connectCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => _log.w('WebSocket connect timeout — continuing offline'),
    );
  }

  void subscribeOrder(String orderId, MessageCallback onMessage) {
    final dest = '/topic/order/$orderId/status';
    _subscribe(dest, onMessage);
  }

  void subscribeChat(String roomId, MessageCallback onMessage) {
    final dest = '/topic/chat.room.$roomId';
    _subscribe(dest, onMessage);
  }

  void subscribeNewRooms(MessageCallback onMessage) {
    _subscribe('/topic/chat.new-room', onMessage);
  }

  void subscribeRoomClaimed(String roomId, MessageCallback onMessage) {
    _subscribe('/topic/chat.claimed.$roomId', onMessage);
  }

  void unsubscribeChat(String roomId) {
    unsubscribe('/topic/chat.room.$roomId');
  }

  void subscribeNotifications(String userId, MessageCallback onMessage) {
    final dest = '/user/$userId/queue/notifications';
    _subscribe(dest, onMessage);
  }

  void _subscribe(String destination, MessageCallback onMessage) {
    if (_subscriptions.containsKey(destination)) return;
    if (_client == null || !isConnected) return;

    final unsub = _client!.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          _log.d('WS message on $destination: ${frame.body}');
          onMessage(frame.body!);
        }
      },
    );

    _subscriptions[destination] = unsub;
  }

  void unsubscribe(String destination) {
    final unsub = _subscriptions.remove(destination);
    if (unsub != null) {
      unsub(unsubscribeHeaders: {});
    }
  }

  void send(String destination, String body) {
    _client?.send(destination: destination, body: body);
  }

  void disconnect() {
    _subscriptions.clear();
    _client?.deactivate();
    _client = null;
    _connectCompleter = null;
    _log.i('WebSocket deactivated');
  }
}
