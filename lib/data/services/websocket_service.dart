import 'dart:async';

import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/constants/api_constants.dart';

typedef MessageCallback = void Function(String body);

class WebSocketService {
  StompClient? _client;
  final Logger _log = Logger();
  final Map<String, StompUnsubscribe> _subscriptions = {};
  // Tracks active callbacks so they can be replayed after reconnect
  final Map<String, MessageCallback> _callbacks = {};
  Completer<void>? _connectCompleter;
  int _errorCount = 0;
  int _connectCount = 0;
  final List<void Function()> _onReconnectListeners = [];

  void addReconnectListener(void Function() listener) {
    _onReconnectListeners.add(listener);
  }

  void removeReconnectListener(void Function() listener) {
    _onReconnectListeners.remove(listener);
  }

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
          final isReconnect = _connectCount > 0;
          _connectCount++;
          if (!_connectCompleter!.isCompleted) {
            _connectCompleter!.complete();
          }
          // Re-subscribe any callbacks that were active before disconnect
          if (_callbacks.isNotEmpty) {
            final toRestore = Map<String, MessageCallback>.from(_callbacks);
            _subscriptions.clear();
            toRestore.forEach(_doSubscribe);
          }
          // Notify listeners on reconnect so they can reload missed data
          if (isReconnect) {
            for (final listener in List.of(_onReconnectListeners)) {
              listener();
            }
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

  void subscribeTyping(String roomId, MessageCallback onMessage) {
    _subscribe('/topic/chat.typing.$roomId', onMessage);
  }

  void unsubscribeTyping(String roomId) {
    unsubscribe('/topic/chat.typing.$roomId');
  }

  void sendTyping(String roomId, bool isTyping) {
    send('/app/chat.typing',
        '{"roomId":$roomId,"typing":$isTyping}');
  }

  void unsubscribeChat(String roomId) {
    unsubscribe('/topic/chat.room.$roomId');
  }

  void subscribeNotifications(String userId, MessageCallback onMessage) {
    final dest = '/user/$userId/queue/notifications';
    _subscribe(dest, onMessage);
  }

  void _subscribe(String destination, MessageCallback onMessage) {
    _callbacks[destination] = onMessage;
    if (_subscriptions.containsKey(destination)) return;
    if (_client == null || !isConnected) {
      // Retry once the connection completes (handles race on screen open)
      _connectCompleter?.future.then((_) {
        if (!_subscriptions.containsKey(destination)) {
          _doSubscribe(destination, onMessage);
        }
      }).catchError((_) {});
      return;
    }
    _doSubscribe(destination, onMessage);
  }

  void _doSubscribe(String destination, MessageCallback onMessage) {
    if (_subscriptions.containsKey(destination)) return;
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
    _callbacks.remove(destination);
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
    _callbacks.clear();
    _client?.deactivate();
    _client = null;
    _connectCompleter = null;
    _log.i('WebSocket deactivated');
  }
}
