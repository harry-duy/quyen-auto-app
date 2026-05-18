import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/staff_router.dart';
import '../../domain/entities/user.dart';

class ManagementHubScreen extends ConsumerWidget {
  const ManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final staffAsync = ref.watch(staffMemberListProvider);
    final deptAsync = ref.watch(departmentListProvider);

    final staffList = staffAsync.valueOrNull ?? [];
    final activeCount = staffList.where((s) => s.isActive).length;
    final deptCount = deptAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Quản lý')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(staffMemberListProvider);
          ref.invalidate(departmentListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Logged-in user card ──────────────────────────────────────
            if (user != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryNavy.withValues(alpha: 0.15)),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryNavy,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        Text(user.position ?? 'Quản trị viên',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textGray)),
                      ],
                    ),
                  ),
                  _RoleBadge(role: user.role),
                ]),
              ),
            const SizedBox(height: 16),

            // ── Stats ────────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_alt,
                  label: 'Nhân viên',
                  value: staffAsync.isLoading ? '…' : '${staffList.length}',
                  sub: staffAsync.isLoading
                      ? ''
                      : '$activeCount đang hoạt động',
                  color: AppColors.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.business,
                  label: 'Phòng ban',
                  value: deptAsync.isLoading ? '…' : '$deptCount',
                  sub: 'Cơ cấu tổ chức',
                  color: AppColors.primaryOrange,
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Navigation tiles ─────────────────────────────────────────
            const _SectionHeader('Nhân sự'),
            const SizedBox(height: 8),
            _NavCard(
              icon: Icons.people_alt_outlined,
              title: 'Quản lý nhân viên',
              subtitle: 'Tạo, chỉnh sửa, phân quyền tài khoản',
              badge: staffAsync.isLoading ? null : '${staffList.length} NV',
              color: AppColors.infoBlue,
              onTap: () => context.push(StaffRoutes.staffMembers),
            ),
            const SizedBox(height: 10),
            _NavCard(
              icon: Icons.business_outlined,
              title: 'Phòng ban',
              subtitle: 'Tổ chức cơ cấu phòng ban trong công ty',
              badge: deptAsync.isLoading ? null : '$deptCount PB',
              color: AppColors.primaryNavy,
              onTap: () => context.push(StaffRoutes.departments),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          if (sub.isNotEmpty)
            Text(sub,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textGray)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textGray,
          letterSpacing: 0.8),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray)),
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ),
          ],
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textGray, size: 20),
        ]),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (role) {
      UserRole.admin => ('Admin', AppColors.errorRed),
      UserRole.manager => ('Manager', AppColors.primaryOrange),
      _ => ('Staff', AppColors.infoBlue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
