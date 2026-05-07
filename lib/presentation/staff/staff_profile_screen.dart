import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/staff_router.dart';
import '../../domain/entities/user.dart';

class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryNavy,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            (user?.fullName.isNotEmpty == true)
                                ? user!.fullName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Staff',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phone ?? '',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textGray),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.email!,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textGray),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _roleColor(user?.role ?? UserRole.staff)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user?.role.label ?? 'Nhân viên',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _roleColor(
                                    user?.role ?? UserRole.staff)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                // Staff details
                if (user?.departmentName != null ||
                    user?.position != null ||
                    user?.employeeCode != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  if (user?.employeeCode != null)
                    _DetailRow(
                        icon: Icons.badge_outlined,
                        label: 'Mã NV',
                        value: user!.employeeCode!),
                  if (user?.departmentName != null)
                    _DetailRow(
                        icon: Icons.business_outlined,
                        label: 'Phòng ban',
                        value: user!.departmentName!),
                  if (user?.position != null)
                    _DetailRow(
                        icon: Icons.work_outline,
                        label: 'Chức vụ',
                        value: user!.position!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Management menu (MANAGER/ADMIN only)
          if (user?.role.isManagerOrAbove == true) ...[
            _SectionTitle(title: 'QUẢN LÝ'),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.business,
              title: 'Quản lý phòng ban',
              subtitle: 'Tạo và chỉnh sửa phòng ban',
              onTap: () => context.push(StaffRoutes.departments),
            ),
            _MenuTile(
              icon: Icons.people,
              title: 'Quản lý nhân viên',
              subtitle: 'Tạo tài khoản, phân quyền',
              onTap: () => context.push(StaffRoutes.staffMembers),
            ),
            const SizedBox(height: 16),
          ],

          // Settings menu
          _SectionTitle(title: 'CÀI ĐẶT'),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Cài đặt thông báo',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.security_outlined,
            title: 'Đổi mật khẩu',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Hủy'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.errorRed),
              label: const Text('Đăng xuất',
                  style: TextStyle(color: AppColors.errorRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorRed),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(UserRole role) => switch (role) {
        UserRole.admin => AppColors.errorRed,
        UserRole.manager => AppColors.primaryOrange,
        UserRole.staff => AppColors.infoBlue,
        UserRole.customer => AppColors.textGray,
      };
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGray,
            letterSpacing: 0.5));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textGray),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGray)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark)),
        ),
      ]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryNavy),
        title: Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textGray))
            : null,
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textGray),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
