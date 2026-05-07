import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 8),
          _MenuSection(title: 'Tài khoản', items: [
            _MenuItem(icon: Icons.person_outline, label: 'Thông tin cá nhân', onTap: () {}),
            _MenuItem(icon: Icons.lock_outline,   label: 'Đổi mật khẩu',     onTap: () {}),
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

class _ProfileHeader extends StatelessWidget {
  final User? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user?.fullName.isNotEmpty == true
        ? user!.fullName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join()
        : 'QA';

    return Container(
      color: AppColors.primaryNavy,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryOrange,
            border: Border.all(color: AppColors.textWhite, width: 2),
          ),
          child: user?.avatarUrl != null
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
          Text(user!.email!, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.6), fontSize: 12)),
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
