import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';

class QuotationTemplateManagementScreen extends ConsumerWidget {
  const QuotationTemplateManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(quotationTemplateListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Mẫu báo giá')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mẫu'),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.textGray,
                    size: 56,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có mẫu báo giá',
                    style: TextStyle(color: AppColors.textGray),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(quotationTemplateListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: templates.length,
              itemBuilder: (_, i) => _TemplateCard(
                template: templates[i],
                onEdit: () =>
                    _showTemplateForm(context, ref, template: templates[i]),
                onToggle: () => _toggleTemplate(context, ref, templates[i]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(color: AppColors.errorRed),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(quotationTemplateListProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTemplate(
    BuildContext context,
    WidgetRef ref,
    QuotationTemplateModel template,
  ) async {
    try {
      await ref
          .read(managementActionsProvider.notifier)
          .toggleQuotationTemplate(template.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              template.isActive ? 'Đã tắt mẫu báo giá' : 'Đã bật mẫu báo giá',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final QuotationTemplateModel template;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: template.isActive
              ? AppColors.borderLight
              : AppColors.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (!template.isActive)
                      const _SmallBadge(
                        label: 'Đã tắt',
                        color: AppColors.errorRed,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (template.categoryName != null) template.categoryName,
                    if (template.productName != null) template.productName,
                    if (template.vehicleModel != null) template.vehicleModel,
                  ].join(' • '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(template.basePrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'toggle') onToggle();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(template.isActive ? 'Tắt mẫu' : 'Bật mẫu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

void _showTemplateForm(
  BuildContext context,
  WidgetRef ref, {
  QuotationTemplateModel? template,
}) {
  final nameCtrl = TextEditingController(text: template?.name ?? '');
  final vehicleCtrl = TextEditingController(text: template?.vehicleModel ?? '');
  final chassisCtrl = TextEditingController(
    text: template?.chassisWidth?.toString() ?? '',
  );
  final boxTypeCtrl = TextEditingController(text: template?.boxType ?? '');
  final acTypeCtrl = TextEditingController(text: template?.acType ?? '');
  final acModelCtrl = TextEditingController(text: template?.acModel ?? '');
  final priceCtrl = TextEditingController(
    text: template != null ? template.basePrice.toStringAsFixed(0) : '',
  );
  final descCtrl = TextEditingController(text: template?.description ?? '');
  final specsCtrl = TextEditingController(text: template?.specifications ?? '');
  final optionCtrl = TextEditingController(text: template?.optionPrices ?? '');
  final noteCtrl = TextEditingController(text: template?.managerNote ?? '');
  final formKey = GlobalKey<FormState>();
  String? selectedCategoryId = template?.categoryId;
  String? selectedProductId = template?.productId;
  bool isActive = template?.isActive ?? true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final categories =
            ref.watch(productCategoryListProvider).valueOrNull ?? [];
        final products = ref.watch(adminProductListProvider).valueOrNull ?? [];
        final visibleProducts = selectedCategoryId == null
            ? products
            : products
                  .where((p) => p.categoryId == selectedCategoryId)
                  .toList();

        return StatefulBuilder(
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
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      template == null
                          ? 'Thêm mẫu báo giá'
                          : 'Chỉnh mẫu báo giá',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên mẫu *',
                        prefixIcon: Icon(Icons.fact_check_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Vui lòng nhập tên mẫu'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Loại / danh mục',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c['id'].toString(),
                              child: Text(c['name'] as String? ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setSheetState(() {
                        selectedCategoryId = value;
                        selectedProductId = null;
                      }),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue:
                          visibleProducts.any((p) => p.id == selectedProductId)
                          ? selectedProductId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Mẫu xe / sản phẩm liên kết',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: visibleProducts
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setSheetState(() {
                        selectedProductId = value;
                        final matches = products.where((p) => p.id == value);
                        final product = matches.isEmpty ? null : matches.first;
                        selectedCategoryId =
                            product?.categoryId ?? selectedCategoryId;
                      }),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: vehicleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên kiểu xe hiển thị',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: chassisCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Rộng chassis',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: boxTypeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Loại thùng',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: acTypeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Loại máy lạnh',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: acModelCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Model máy lạnh',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Giá nền nội bộ (VNĐ) *',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập giá nền';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: specsCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Thông số mặc định (JSON)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: optionCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Bảng giá option (JSON)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: noteCtrl,
                      minLines: 2,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú manager',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) =>
                          setSheetState(() => isActive = value),
                      title: const Text('Đang sử dụng'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          template == null ? Icons.add : Icons.save_outlined,
                        ),
                        label: Text(template == null ? 'Thêm mẫu' : 'Lưu mẫu'),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);
                          try {
                            final notifier = ref.read(
                              managementActionsProvider.notifier,
                            );
                            if (template == null) {
                              await notifier.createQuotationTemplate(
                                name: nameCtrl.text.trim(),
                                categoryId: selectedCategoryId,
                                productId: selectedProductId,
                                description: descCtrl.text.trim(),
                                vehicleModel: vehicleCtrl.text.trim(),
                                chassisWidth: int.tryParse(
                                  chassisCtrl.text.trim(),
                                ),
                                boxType: boxTypeCtrl.text.trim(),
                                acType: acTypeCtrl.text.trim(),
                                acModel: acModelCtrl.text.trim(),
                                specifications: specsCtrl.text.trim(),
                                basePrice: double.parse(priceCtrl.text.trim()),
                                optionPrices: optionCtrl.text.trim(),
                                managerNote: noteCtrl.text.trim(),
                                isActive: isActive,
                              );
                            } else {
                              await notifier.updateQuotationTemplate(
                                id: template.id,
                                name: nameCtrl.text.trim(),
                                categoryId: selectedCategoryId,
                                productId: selectedProductId,
                                description: descCtrl.text.trim(),
                                vehicleModel: vehicleCtrl.text.trim(),
                                chassisWidth: int.tryParse(
                                  chassisCtrl.text.trim(),
                                ),
                                boxType: boxTypeCtrl.text.trim(),
                                acType: acTypeCtrl.text.trim(),
                                acModel: acModelCtrl.text.trim(),
                                specifications: specsCtrl.text.trim(),
                                basePrice: double.parse(priceCtrl.text.trim()),
                                optionPrices: optionCtrl.text.trim(),
                                managerNote: noteCtrl.text.trim(),
                                isActive: isActive,
                              );
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    template == null
                                        ? 'Đã thêm mẫu báo giá'
                                        : 'Đã cập nhật mẫu báo giá',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: $e'),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

String _formatPrice(double price) {
  if (price >= 1000000) {
    final value = price / 1000000;
    return '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} triệu đồng';
  }
  return '${price.toStringAsFixed(0)} đồng';
}
