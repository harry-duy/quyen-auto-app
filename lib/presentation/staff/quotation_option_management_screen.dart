import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';

class QuotationOptionManagementScreen extends ConsumerWidget {
  const QuotationOptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(quotationOptionListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Kho option báo giá')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOptionForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm option'),
      ),
      body: optionsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có option báo giá',
                style: TextStyle(color: AppColors.textGray),
              ),
            );
          }

          final grouped = <String, List<QuotationOptionModel>>{};
          for (final option in options) {
            grouped.putIfAbsent(option.position, () => []).add(option);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(quotationOptionListProvider),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: grouped.entries
                  .map(
                    (entry) => _OptionPositionSection(
                      position: entry.key,
                      options: entry.value,
                      onEdit: (option) =>
                          _showOptionForm(context, ref, option: option),
                      onToggle: (option) => _toggleOption(context, ref, option),
                    ),
                  )
                  .toList(),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Lỗi tải kho option: $e',
            style: const TextStyle(color: AppColors.errorRed),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleOption(
    BuildContext context,
    WidgetRef ref,
    QuotationOptionModel option,
  ) async {
    try {
      await ref
          .read(managementActionsProvider.notifier)
          .toggleQuotationOption(option.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }
}

class _OptionPositionSection extends StatelessWidget {
  final String position;
  final List<QuotationOptionModel> options;
  final ValueChanged<QuotationOptionModel> onEdit;
  final ValueChanged<QuotationOptionModel> onToggle;

  const _OptionPositionSection({
    required this.position,
    required this.options,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              _positionLabel(position),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          ...options.map(
            (option) => ListTile(
              title: Text(option.name),
              subtitle: Text(
                '${_formatMoney(option.defaultPrice)} / ${option.unit}',
              ),
              leading: Icon(
                option.isActive
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
                color: option.isActive
                    ? AppColors.successGreen
                    : AppColors.textGray,
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit(option);
                  if (value == 'toggle') onToggle(option);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(option.isActive ? 'Tắt option' : 'Bật option'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showOptionForm(
  BuildContext context,
  WidgetRef ref, {
  QuotationOptionModel? option,
}) {
  final nameCtrl = TextEditingController(text: option?.name ?? '');
  final unitCtrl = TextEditingController(text: option?.unit ?? 'cái');
  final priceCtrl = TextEditingController(
    text: option == null ? '' : option.defaultPrice.toStringAsFixed(0),
  );
  final descCtrl = TextEditingController(text: option?.description ?? '');
  final noteCtrl = TextEditingController(text: option?.internalNote ?? '');
  var position = option?.position ?? 'FLOOR';
  var isActive = option?.isActive ?? true;
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option == null ? 'Thêm option' : 'Chỉnh option',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên option *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nhập tên option' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: position,
                  decoration: const InputDecoration(
                    labelText: 'Vị trí',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FLOOR', child: Text('Sàn')),
                    DropdownMenuItem(value: 'DOOR', child: Text('Cửa')),
                    DropdownMenuItem(
                      value: 'WALL',
                      child: Text('Vách / hông / nóc'),
                    ),
                    DropdownMenuItem(value: 'AC', child: Text('Máy lạnh')),
                    DropdownMenuItem(value: 'LIGHT', child: Text('Đèn')),
                    DropdownMenuItem(
                      value: 'ACCESSORY',
                      child: Text('Phụ kiện'),
                    ),
                    DropdownMenuItem(value: 'OTHER', child: Text('Khác')),
                  ],
                  onChanged: (v) =>
                      setSheetState(() => position = v ?? position),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Đơn vị',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Giá mặc định',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nhập giá' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú nội bộ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đang dùng'),
                  value: isActive,
                  onChanged: (v) => setSheetState(() => isActive = v),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu option'),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      final actions = ref.read(
                        managementActionsProvider.notifier,
                      );
                      if (option == null) {
                        await actions.createQuotationOption(
                          name: nameCtrl.text.trim(),
                          position: position,
                          unit: unitCtrl.text.trim(),
                          defaultPrice: double.parse(priceCtrl.text.trim()),
                          description: descCtrl.text.trim(),
                          internalNote: noteCtrl.text.trim(),
                          isActive: isActive,
                        );
                      } else {
                        await actions.updateQuotationOption(
                          id: option.id,
                          name: nameCtrl.text.trim(),
                          position: position,
                          unit: unitCtrl.text.trim(),
                          defaultPrice: double.parse(priceCtrl.text.trim()),
                          description: descCtrl.text.trim(),
                          internalNote: noteCtrl.text.trim(),
                          isActive: isActive,
                        );
                      }
                    },
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

String _positionLabel(String value) => switch (value.toUpperCase()) {
  'FLOOR' => 'Sàn',
  'DOOR' => 'Cửa',
  'WALL' => 'Vách / hông / nóc',
  'AC' => 'Máy lạnh',
  'LIGHT' => 'Đèn',
  'ACCESSORY' => 'Phụ kiện',
  _ => 'Khác',
};

String _formatMoney(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }
  return '$bufferđ';
}
