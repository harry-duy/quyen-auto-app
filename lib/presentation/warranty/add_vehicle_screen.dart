import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';

/// Vehicles are registered by staff at contract signing.
/// This screen informs the customer about the process.
class AddVehicleScreen extends ConsumerWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký xe bảo hành')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryNavy,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Xe của bạn sẽ được đăng ký bảo hành tự động',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sau khi ký hợp đồng mua xe, nhân viên sẽ đăng ký '
                'thông tin xe và kích hoạt bảo hành cho bạn. '
                'Xe sẽ xuất hiện trong tab "Xe của tôi" khi đã được đăng ký.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
