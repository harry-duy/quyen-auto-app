import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/constants/app_colors.dart';

/// Màn hình thông tin đăng ký xe.
///
/// Hiện tại xe được đăng ký bởi nhân viên Quyen Auto sau khi giao dịch.
/// Khách hàng liên hệ hotline hoặc showroom để đăng ký xe bảo hành.
class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Đăng ký xe bảo hành')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.car_repair,
                    color: AppColors.primaryNavy, size: 42),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng ký xe bảo hành',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Xe được đăng ký vào hệ thống bảo hành bởi nhân viên Quyen Auto sau khi hoàn tất giao dịch mua xe.\n\nNếu xe của bạn chưa được đăng ký, vui lòng liên hệ chúng tôi qua:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Hotline button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => launchUrlString('tel:0908109929'),
                  icon: const Icon(Icons.phone),
                  label: const Text('Gọi Hotline: 0908 109 929'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Zalo button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      launchUrlString('https://zalo.me/0908109929'),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Chat Zalo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
