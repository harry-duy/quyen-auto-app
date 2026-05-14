import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
            onTap: () => _showEditProfileSheet(context, ref, user),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Cài đặt thông báo',
            onTap: () => context.push(StaffRoutes.notifications),
          ),
          _MenuTile(
            icon: Icons.security_outlined,
            title: 'Đổi mật khẩu',
            onTap: () => _showChangePasswordSheet(context, ref),
          ),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            onTap: () => _showHelpSheet(context),
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

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, User? user) {
    final nameCtrl =
        TextEditingController(text: user?.fullName ?? '');
    final emailCtrl =
        TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin cá nhân',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  Navigator.pop(ctx);
                  try {
                    await ref
                        .read(authProvider.notifier)
                        .updateProfile(
                          fullName:
                              name.isNotEmpty ? name : null,
                          email:
                              email.isNotEmpty ? email : null,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                        content:
                            Text('Đã cập nhật thông tin'),
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: AppColors.errorRed,
                      ));
                    }
                  }
                },
                child: const Text('Lưu thay đổi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        bool showCurrent = false;
        bool showNew = false;
        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đổi mật khẩu',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: currentCtrl,
                  obscureText: !showCurrent,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(showCurrent
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showCurrent = !showCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: !showNew,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(showNew
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showNew = !showNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final current = currentCtrl.text.trim();
                      final newPwd = newCtrl.text.trim();
                      final confirm = confirmCtrl.text.trim();
                      if (current.isEmpty || newPwd.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Vui lòng điền đầy đủ'),
                                backgroundColor: AppColors.warningAmber));
                        return;
                      }
                      if (newPwd != confirm) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Mật khẩu xác nhận không khớp'),
                                backgroundColor: AppColors.warningAmber));
                        return;
                      }
                      if (newPwd.length < 6) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Mật khẩu mới phải ít nhất 6 ký tự'),
                                backgroundColor: AppColors.warningAmber));
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        await ref
                            .read(authProvider.notifier)
                            .changePassword(
                              currentPassword: current,
                              newPassword: newPwd,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Đã đổi mật khẩu thành công')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: AppColors.errorRed));
                        }
                      }
                    },
                    child: const Text('Đổi mật khẩu'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trợ giúp & Liên hệ',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text(
              'Nếu gặp vấn đề trong quá trình sử dụng ứng dụng, vui lòng liên hệ bộ phận kỹ thuật:',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textGray),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone,
                    color: AppColors.primaryOrange, size: 20),
              ),
              title: const Text('Hotline nội bộ',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('0908 109 929',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textGray)),
              onTap: () => launchUrlString('tel:0908109929'),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoBlue
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.email_outlined,
                    color: AppColors.infoBlue, size: 20),
              ),
              title: const Text('Email hỗ trợ',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('support@quyenauto.vn',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textGray)),
              onTap: () => launchUrlString(
                  'mailto:support@quyenauto.vn'),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
