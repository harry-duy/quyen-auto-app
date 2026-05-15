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

  bool get isConnected => _client != null && _connectCompleter?.isCompleted == true;

  Future<void> connect({required String token}) async {
    if (isConnected) return;

    _connectCompleter = Completer<void>();

    _client = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (frame) {
          _log.i('WebSocket connected');
          if (!_connectCompleter!.isCompleted) {
            _connectCompleter!.complete();
          }
        },
        onWebSocketError: (err) {
          _log.e('WS Error: $err');
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.completeError(err);
          }
        },
        onStompError: (frame) => _log.e('STOMP Error: ${frame.body}'),
        onDisconnect: (_) {
          _log.w('WebSocket disconnected');
          _subscriptions.clear();
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 5),
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
    final dest = '/topic/room/$roomId';
    _subscribe(dest, onMessage);
  }

  void subscribeStaffQuotations(MessageCallback onMessage) {
    const dest = '/topic/staff/quotations';
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
