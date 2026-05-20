import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/user.dart';

class StaffMemberManagementScreen extends ConsumerWidget {
  const StaffMemberManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(staffMemberListProvider);
    final deptFilter = ref.watch(staffMemberDepartmentFilter);
    final deptsAsync = ref.watch(departmentListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Quản lý nhân viên')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateStaffForm(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // Department filter
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                _FilterChipItem(
                  label: 'Tất cả',
                  isSelected: deptFilter == null,
                  onTap: () => ref
                      .read(staffMemberDepartmentFilter.notifier)
                      .state = null,
                ),
                ...deptsAsync.valueOrNull?.map((dept) => _FilterChipItem(
                      label: dept.name,
                      isSelected: deptFilter == dept.id,
                      onTap: () => ref
                          .read(staffMemberDepartmentFilter.notifier)
                          .state = dept.id,
                    )) ??
                    [],
              ]),
            ),
          ),
          const Divider(height: 1),

          // Staff list
          Expanded(
            child: membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            color: AppColors.textGray, size: 48),
                        SizedBox(height: 8),
                        Text('Chưa có nhân viên',
                            style: TextStyle(
                                color: AppColors.textGray, fontSize: 14)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(staffMemberListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: members.length,
                    itemBuilder: (_, i) =>
                        _StaffMemberCard(member: members[i]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(e.toString(),
                    style: const TextStyle(color: AppColors.errorRed)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        selectedColor: AppColors.primaryOrange.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryOrange,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color:
              isSelected ? AppColors.primaryOrange : AppColors.textGray,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _StaffMemberCard extends ConsumerWidget {
  final User member;
  const _StaffMemberCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryNavy,
          backgroundImage: member.avatarUrl != null
              ? NetworkImage(member.avatarUrl!)
              : null,
          child: member.avatarUrl == null
              ? Text(
                  member.fullName.isNotEmpty
                      ? member.fullName[0].toUpperCase()
                      : 'S',
                  style: const TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 16))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(member.fullName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _roleColor(member.role).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    member.role.label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _roleColor(member.role)),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.phone_outlined,
                    size: 13, color: AppColors.textGray),
                const SizedBox(width: 4),
                Text(member.phone,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray)),
              ]),
              if (member.departmentName != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.business_outlined,
                      size: 13, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Text(member.departmentName!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGray)),
                  if (member.position != null) ...[
                    const Text(' · ',
                        style: TextStyle(color: AppColors.textGray)),
                    Text(member.position!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray)),
                  ],
                ]),
              ],
              if (member.employeeCode != null) ...[
                const SizedBox(height: 2),
                Text('Mã NV: ${member.employeeCode}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGray)),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (action) =>
              _handleAction(context, ref, action, member),
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'edit', child: Text('Chỉnh sửa')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(member.isActive
                  ? 'Vô hiệu hóa'
                  : 'Kích hoạt lại'),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: AppColors.textGray),
        ),
      ]),
    );
  }

  Color _roleColor(UserRole role) => switch (role) {
        UserRole.admin => AppColors.errorRed,
        UserRole.manager => AppColors.primaryOrange,
        UserRole.staff => AppColors.infoBlue,
        UserRole.customer => AppColors.textGray,
      };

  void _handleAction(
      BuildContext context, WidgetRef ref, String action, User member) {
    if (action == 'toggle') {
      _confirmToggle(context, ref, member);
    } else if (action == 'edit') {
      _showEditForm(context, ref, member);
    }
  }

  void _confirmToggle(
      BuildContext context, WidgetRef ref, User member) {
    final action = member.isActive ? 'vô hiệu hóa' : 'kích hoạt lại';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${member.isActive ? "Vô hiệu hóa" : "Kích hoạt"} tài khoản'),
        content: Text('Bạn có chắc muốn $action tài khoản ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: member.isActive
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorRed)
                : null,
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(managementActionsProvider.notifier)
                    .toggleStaffActive(member.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã $action tài khoản')),
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
            child: Text(member.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
          ),
        ],
      ),
    );
  }

  void _showEditForm(BuildContext context, WidgetRef ref, User member) {
    final nameCtrl = TextEditingController(text: member.fullName);
    final emailCtrl = TextEditingController(text: member.email ?? '');
    final posCtrl = TextEditingController(text: member.position ?? '');
    String? selectedRole = member.role.name.toUpperCase();
    String? selectedDeptId = member.departmentId;
    final deptsAsync = ref.read(departmentListProvider);
    final depts = deptsAsync.valueOrNull ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Chỉnh sửa — ${member.fullName}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                      value: 'STAFF', child: Text('Nhân viên')),
                  DropdownMenuItem<String>(
                      value: 'MANAGER', child: Text('Quản lý')),
                  DropdownMenuItem<String>(
                      value: 'ADMIN', child: Text('Quản trị viên')),
                ],
                onChanged: (v) => setState(() => selectedRole = v),
              ),
              const SizedBox(height: 10),
              if (depts.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: selectedDeptId,
                  decoration: const InputDecoration(
                    labelText: 'Phòng ban',
                    border: OutlineInputBorder(),
                  ),
                  items: depts
                      .map((d) => DropdownMenuItem<String>(
                          value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedDeptId = v),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: posCtrl,
                decoration: const InputDecoration(
                  labelText: 'Chức vụ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(managementActionsProvider.notifier)
                          .updateStaffMember(
                            id: member.id,
                            fullName: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim().isEmpty
                                ? null
                                : emailCtrl.text.trim(),
                            role: selectedRole,
                            departmentId: selectedDeptId,
                            position: posCtrl.text.trim().isEmpty
                                ? null
                                : posCtrl.text.trim(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Đã cập nhật nhân viên')),
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
                  child: const Text('Cập nhật'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showCreateStaffForm(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final posCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedRole = 'STAFF';
  String? selectedDeptId;
  final deptsAsync = ref.read(departmentListProvider);
  final depts = deptsAsync.valueOrNull ?? [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tạo tài khoản nhân viên',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => Validators.required(v, 'Họ tên'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu *',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Vai trò *',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                        value: 'STAFF', child: Text('Nhân viên')),
                    DropdownMenuItem<String>(
                        value: 'MANAGER', child: Text('Quản lý')),
                    DropdownMenuItem<String>(
                        value: 'ADMIN', child: Text('Quản trị viên')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => selectedRole = v);
                  },
                ),
                const SizedBox(height: 10),
                if (depts.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: selectedDeptId,
                    decoration: const InputDecoration(
                      labelText: 'Phòng ban',
                      prefixIcon: Icon(Icons.business_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: depts
                        .map((d) => DropdownMenuItem<String>(
                            value: d.id, child: Text(d.name)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedDeptId = v),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: posCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chức vụ',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      try {
                        await ref
                            .read(managementActionsProvider.notifier)
                            .createStaffAccount(
                              fullName: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              password: passCtrl.text,
                              role: selectedRole,
                              email: emailCtrl.text.trim().isEmpty
                                  ? null
                                  : emailCtrl.text.trim(),
                              departmentId: selectedDeptId,
                              position: posCtrl.text.trim().isEmpty
                                  ? null
                                  : posCtrl.text.trim(),
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Đã tạo tài khoản nhân viên')),
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
                    icon: const Icon(Icons.person_add),
                    label: const Text('Tạo tài khoản'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
