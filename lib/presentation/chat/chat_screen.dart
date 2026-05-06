import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement Chat screen with WebSocket / STOMP

class ChatScreen extends ConsumerWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ trực tuyến')),
      body: Center(child: Text('Chat Room: $roomId — Coming Soon')),
    );
  }
}
