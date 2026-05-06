import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement Bảo hành screen

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảo hành')),
      body: const Center(child: Text('Bảo hành — Coming Soon')),
    );
  }
}
