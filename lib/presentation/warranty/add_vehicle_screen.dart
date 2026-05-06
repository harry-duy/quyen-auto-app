import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement Add Vehicle screen

class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm xe')),
      body: const Center(child: Text('Add Vehicle — Coming Soon')),
    );
  }
}
