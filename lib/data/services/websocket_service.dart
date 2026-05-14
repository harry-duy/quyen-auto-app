import 'dart:async';

import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/constants/api_constants.dart';

typedef MessageCallback = void Function(String body);

/// WebSocket service voi:
/// - Exponential backoff reconnect (2s, 4s, 8s, ... max 60s)
/// - Tu dong re-subscribe tat ca topic sau khi reconnect
/// - An toan khi disconnect co chu dich (goi `disconnect()`)
class WebSocketService {
  StompClient? _client;
  final Logger _log = Logger();

  // Luu callback de re-subscribe sau khi reconnect
  final Map<String, MessageCallback> _subscriptionCallbacks = {};
  // Active STOMP unsub handles
  final Map<String, StompUnsubscribe> _activeSubscriptions = {};

  Completer<void>? _connectCompleter;
  bool _intentionalDisconnect = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  String? _lastToken;

  static const int _baseDelaySeconds = 2;
  static const int _maxDelaySeconds  = 60;

  bool get isConnected =>
      _client != null && _connectCompleter?.isCompleted == true;

  // ─── Public API ─────────────────────────────────────────────────────────────

  Future<void> connect({required String token}) async {
    if (isConnected) return;
    _lastToken             = token;
    _intentionalDisconnect = false;
    _reconnectAttempt      = 0;
    await _doConnect(token);
  }

  void subscribeOrder(String orderId, MessageCallback onMessage) {
    final dest = '/topic/order/$orderId/status';
    _subscriptionCallbacks[dest] = onMessage;
    if (isConnected) _doSubscribe(dest, onMessage);
  }

  void subscribeChat(String roomId, MessageCallback onMessage) {
    final dest = '/topic/chat.room.$roomId';
    _subscriptionCallbacks[dest] = onMessage;
    if (isConnected) _doSubscribe(dest, onMessage);
  }

  void unsubscribe(String destination) {
    _subscriptionCallbacks.remove(destination);
    final unsub = _activeSubscriptions.remove(destination);
    unsub?.call(unsubscribeHeaders: {});
  }

  void send(String destination, String body) {
    if (!isConnected) {
      _log.w('send() called while disconnected — message dropped');
      return;
    }
    _client!.send(destination: destination, body: body);
  }

  void disconnect() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscriptionCallbacks.clear();
    _activeSubscriptions.clear();
    _client?.deactivate();
    _client            = null;
    _connectCompleter  = null;
    _lastToken         = null;
    _reconnectAttempt  = 0;
    _log.i('WebSocket deactivated (intentional)');
  }

  // ─── Internal ───────────────────────────────────────────────────────────────

  Future<void> _doConnect(String token) async {
    _connectCompleter = Completer<void>();

    _client = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,

        onConnect: (frame) {
          _log.i('WebSocket connected${_reconnectAttempt > 0 ? ' (retry #$_reconnectAttempt)' : ''}');
          _reconnectAttempt = 0;
          _resubscribeAll();
          if (!_connectCompleter!.isCompleted) {
            _connectCompleter!.complete();
          }
        },

        onWebSocketError: (err) {
          _log.e('WS error: $err');
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.completeError(err);
          }
          // onDisconnect se duoc goi sau, schedule reconnect o day
        },

        onStompError: (frame) => _log.e('STOMP error: ${frame.body}'),

        onDisconnect: (_) {
          _log.w('WebSocket disconnected');
          _activeSubscriptions.clear();
          if (!_intentionalDisconnect) {
            _scheduleReconnect();
          }
        },

        stompConnectHeaders:    {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},

        // Tat auto-reconnect cua stomp — chung ta tu xu ly de co backoff
        reconnectDelay: const Duration(days: 1),
      ),
    );

    _client!.activate();

    return _connectCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _log.w('WebSocket connect timeout — app continues offline');
        // Timeout => coi nhu disconnect, se schedule reconnect qua onDisconnect
      },
    );
  }

  /// Exponential backoff: 2s, 4s, 8s, 16s, 32s, 60s, 60s, ...
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_lastToken == null || _intentionalDisconnect) return;

    _reconnectAttempt++;
    final exp          = _reconnectAttempt - 1;
    final rawDelay     = _baseDelaySeconds * (1 << exp.clamp(0, 5)); // 2^0..2^5 = 1..32 -> *2 = 2..64
    final delaySeconds = rawDelay.clamp(_baseDelaySeconds, _maxDelaySeconds);

    _log.i('Scheduling WS reconnect in ${delaySeconds}s (attempt #$_reconnectAttempt)');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_intentionalDisconnect && _lastToken != null) {
        _log.i('Reconnecting WebSocket (attempt #$_reconnectAttempt)...');
        _client?.deactivate();
        _client           = null;
        _connectCompleter = null;
        _doConnect(_lastToken!);
      }
    });
  }

  void _resubscribeAll() {
    if (_subscriptionCallbacks.isEmpty) return;
    _log.i('Re-subscribing ${_subscriptionCallbacks.length} topic(s) after reconnect');
    for (final entry in _subscriptionCallbacks.entries) {
      _doSubscribe(entry.key, entry.value);
    }
  }

  void _doSubscribe(String destination, MessageCallback onMessage) {
    if (_activeSubscriptions.containsKey(destination)) return;
    if (_client == null || !isConnected) return;

    final unsub = _client!.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          _log.d('WS msg on $destination: ${frame.body}');
          onMessage(frame.body!);
        }
      },
    );

    _activeSubscriptions[destination] = unsub;
  }
}
