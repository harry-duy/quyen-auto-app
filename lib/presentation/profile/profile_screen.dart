import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Tài khoản'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Column(children: [
          _ProfileHeader(user: user),
          // Banner xac minh email neu chua xac minh
          if (user != null && !user.emailVerified && user.email != null)
            _EmailVerifyBanner(onTap: () => context.push(AppRoutes.verifyOtp)),
          const SizedBox(height: 8),
          _MenuSection(title: 'Quản lý đơn hàng', items: [
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'Đơn hàng của tôi',
              onTap: () => ref.read(homeTabIndexProvider.notifier).state = 2,
            ),
            _MenuItem(icon: Icons.request_quote_outlined, label: 'Yêu cầu báo giá',    onTap: () => context.push(AppRoutes.quotation)),
          ]),
          const SizedBox(height: 8),
          _MenuSection(title: 'Tiện ích', items: [
            _MenuItem(icon: Icons.notifications_outlined, label: 'Thông báo',           onTap: () => context.push(AppRoutes.notifications)),
            _MenuItem(
              icon: Icons.shield_outlined,
              label: 'Bảo hành xe',
              onTap: () => ref.read(homeTabIndexProvider.notifier).state = 3,
            ),
            _MenuItem(
              icon: Icons.support_agent_outlined,
              label: 'Hỗ trợ khách hàng',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primaryOrange, borderRadius: BorderRadius.circular(10)),
                child: const Text('Chat', style: TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              onTap: () => context.push(AppRoutes.chatList),
            ),
          ]),
          const SizedBox(height: 8),
          _MenuSection(title: 'Tài khoản', items: [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Thông tin cá nhân',
              onTap: () => _showEditProfileSheet(context, ref, user),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              label: 'Đổi mật khẩu',
              onTap: () => _showChangePasswordSheet(context, ref),
            ),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.textGray),
                  title: const Text('Phiên bản', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
                  trailing: const Text('1.0.0', style: TextStyle(fontSize: 13, color: AppColors.textGray)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.errorRed),
                  title: const Text('Đăng xuất',
                      style: TextStyle(fontSize: 14, color: AppColors.errorRed, fontWeight: FontWeight.w600)),
                  onTap: () => _confirmLogout(context, ref),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 32),
        ]),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                    await ref.read(authProvider.notifier).updateProfile(
                          fullName:
                              name.isNotEmpty ? name : null,
                          email: email.isNotEmpty ? email : null,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Đã cập nhật thông tin cá nhân')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: AppColors.errorRed),
                      );
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                      final newPwd  = newCtrl.text.trim();
                      final confirm = confirmCtrl.text.trim();
                      if (current.isEmpty || newPwd.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Vui lòng điền đầy đủ thông tin'),
                                backgroundColor: AppColors.warningAmber));
                        return;
                      }
                      if (newPwd != confirm) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                                content: Text('Mật khẩu mới không khớp'),
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
                                  content: Text('Đã đổi mật khẩu thành công')));
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

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerStatefulWidget {
  final User? user;
  const _ProfileHeader({required this.user});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _uploading = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final file = File(picked.path);
      final api = ref.read(apiServiceProvider);
      final url = await api.uploadFile(file, folder: 'avatars');
      await ref.read(authProvider.notifier).updateProfile(avatarUrl: url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload ảnh: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = user?.fullName.isNotEmpty == true
        ? user!.fullName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join()
        : 'QA';

    return Container(
      color: AppColors.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(children: [
        GestureDetector(
          onTap: _uploading ? null : _pickAndUploadAvatar,
          child: Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                  border: Border.all(color: AppColors.textWhite, width: 2),
                ),
                child: _uploading
                    ? const Center(
                        child: SizedBox(
                          width: 28, height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : user?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(user!.avatarUrl!, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(initials,
                                      style: const TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.w800)),
                                )))
                        : Center(
                            child: Text(initials,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 26, fontWeight: FontWeight.w800))),
              ),
              // Camera badge overlay
              if (!_uploading)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryOrange,
                    ),
                    child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.fullName.isNotEmpty == true ? user!.fullName : 'Quý khách',
          style: const TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        if (user?.phone.isNotEmpty == true)
          Text(user!.phone, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.7), fontSize: 14)),
        if (user?.email != null && user!.email!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(user.email!, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.6), fontSize: 12)),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
          ),
          child: Text(
            user?.role.label ?? 'Khách hàng',
            style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// ── Banner xac minh email ─────────────────────────────────────────────────────

class _EmailVerifyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _EmailVerifyBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warningAmber),
        ),
        child: Row(
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                color: AppColors.warningAmber, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email chưa được xác minh',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF795548)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Nhấn để xác minh ngay và bảo mật tài khoản',
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGray, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: items.asMap().entries.map((e) => Column(children: [
              e.value,
              if (e.key < items.length - 1) const Divider(height: 1, indent: 56),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.primaryNavy, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textGray, size: 20),
      onTap: onTap,
    );
  }
}
