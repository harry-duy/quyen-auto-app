import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';
import '../../domain/entities/department.dart';

class DepartmentManagementScreen extends ConsumerWidget {
  const DepartmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptAsync = ref.watch(departmentListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Phòng ban')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDepartmentForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: deptAsync.when(
        data: (departments) {
          if (departments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_outlined,
                      color: AppColors.textGray, size: 48),
                  SizedBox(height: 8),
                  Text('Chưa có phòng ban nào',
                      style: TextStyle(color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(departmentListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: departments.length,
              itemBuilder: (_, i) =>
                  _DepartmentCard(department: departments[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 40),
              const SizedBox(height: 8),
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentCard extends ConsumerWidget {
  final Department department;
  const _DepartmentCard({required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business,
                  color: AppColors.primaryNavy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(department.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  if (department.description != null) ...[
                    const SizedBox(height: 2),
                    Text(department.description!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showDepartmentForm(
                  context, ref, existing: department),
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textGray, size: 20),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _InfoChip(
              icon: Icons.people_outline,
              label: '${department.staffCount} nhân viên',
            ),
            const SizedBox(width: 12),
            if (department.managerName != null)
              _InfoChip(
                icon: Icons.manage_accounts_outlined,
                label: department.managerName!,
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: department.isActive
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                department.isActive ? 'Hoạt động' : 'Ngưng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: department.isActive
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textGray),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
      ],
    );
  }
}

void _showDepartmentForm(BuildContext context, WidgetRef ref,
    {Department? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  final formKey = GlobalKey<FormState>();
  final isEditing = existing != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Form(
        key: formKey,
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
            Text(
              isEditing ? 'Sửa phòng ban' : 'Thêm phòng ban',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên phòng ban *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  try {
                    if (isEditing) {
                      await ref
                          .read(managementActionsProvider.notifier)
                          .updateDepartment(
                            id: existing.id,
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                          );
                    } else {
                      await ref
                          .read(managementActionsProvider.notifier)
                          .createDepartment(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                          );
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEditing
                            ? 'Đã cập nhật phòng ban'
                            : 'Đã tạo phòng ban'),
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: AppColors.errorRed,
                      ));
                    }
                  }
                },
                child: Text(isEditing ? 'Cập nhật' : 'Tạo mới'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
