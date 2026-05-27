import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Qu?n l� s?n ph?m')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      color: AppColors.textGray, size: 56),
                  SizedBox(height: 12),
                  Text('Chua c� s?n ph?m n�o',
                      style: TextStyle(color: AppColors.textGray)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminProductListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductCard(
                product: products[i],
                onEdit: () => _showProductForm(context, ref, product: products[i]),
                onDelete: () => _confirmDelete(context, ref, products[i]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 48),
              const SizedBox(height: 8),
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(adminProductListProvider),
                child: const Text('Th? l?i'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AdminProduct product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xo� s?n ph?m'),
        content: Text(
            'B?n c� ch?c mu?n xo� "${product.name}"?\nS?n ph?m s? b? ?n kh?i danh s�ch.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hu?')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(managementActionsProvider.notifier)
                    .deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('�� xo� s?n ph?m')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('L?i: $e'),
                        backgroundColor: AppColors.errorRed),
                  );
                }
              }
            },
            child: const Text('Xo�'),
          ),
        ],
      ),
    );
  }
}

// --- Product card -------------------------------------------------------------

class _ProductCard extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.isActive
              ? AppColors.borderLight
              : AppColors.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.imageUrls.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primaryNavy)),
                )
              : const Icon(Icons.inventory_2_outlined,
                  color: AppColors.primaryNavy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(product.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ),
                if (!product.isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('�� ?n',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorRed)),
                  ),
              ]),
              const SizedBox(height: 3),
              if (product.categoryName != null)
                Text(product.categoryName!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray)),
              const SizedBox(height: 2),
              Text(
                _formatPrice(product.basePrice),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Ch?nh s?a')),
            PopupMenuItem(
                value: 'delete',
                child: Text('Xo�', style: TextStyle(color: Colors.red))),
          ],
          icon: const Icon(Icons.more_vert, color: AppColors.textGray),
        ),
      ]),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)} tri?u d?ng';
    }
    return '${price.toStringAsFixed(0)} d?ng';
  }
}

// --- Product form (create / edit) --------------------------------------------

void _showProductForm(BuildContext context, WidgetRef ref,
    {AdminProduct? product}) {
  final nameCtrl =
      TextEditingController(text: product?.name ?? '');
  final priceCtrl = TextEditingController(
      text: product != null ? product.basePrice.toStringAsFixed(0) : '');
  final descCtrl =
      TextEditingController(text: product?.description ?? '');
  final specsCtrl =
      TextEditingController(text: product?.specifications ?? '');
  final formKey = GlobalKey<FormState>();
  String? selectedCategoryId = product?.categoryId;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final categoriesAsync = ref.watch(productCategoryListProvider);
        final categories = categoriesAsync.valueOrNull ?? [];

        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
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
                      product == null
                          ? 'Th�m s?n ph?m m?i'
                          : 'Ch?nh s?a s?n ph?m',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'T�n s?n ph?m *',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Vui l�ng nh?p t�n s?n ph?m'
                              : null,
                    ),
                    const SizedBox(height: 10),

                    if (categories.isNotEmpty)
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Danh m?c *',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem<String>(
                                  value: c['id'].toString(),
                                  child: Text(c['name'] as String? ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCategoryId = v),
                        validator: (v) =>
                            v == null ? 'Vui l�ng ch?n danh m?c' : null,
                      ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Gi� co b?n (VN�) *',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui l�ng nh?p gi�';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Gi� kh�ng h?p l?';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'M� t?',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: specsCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Th�ng s? k? thu?t',
                        prefixIcon: Icon(Icons.settings_outlined),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedCategoryId == null) return;
                          Navigator.pop(ctx);
                          try {
                            final catId = int.parse(selectedCategoryId!);
                            final price =
                                double.parse(priceCtrl.text.trim());
                            if (product == null) {
                              await ref
                                  .read(managementActionsProvider.notifier)
                                  .createProduct(
                                    name: nameCtrl.text.trim(),
                                    categoryId: catId,
                                    basePrice: price,
                                    description: descCtrl.text.trim(),
                                    specifications: specsCtrl.text.trim(),
                                  );
                            } else {
                              await ref
                                  .read(managementActionsProvider.notifier)
                                  .updateProduct(
                                    id: product.id,
                                    name: nameCtrl.text.trim(),
                                    categoryId: catId,
                                    basePrice: price,
                                    description: descCtrl.text.trim(),
                                    specifications: specsCtrl.text.trim(),
                                  );
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(product == null
                                        ? '�� th�m s?n ph?m'
                                        : '�� c?p nh?t s?n ph?m')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('L?i: $e'),
                                    backgroundColor: AppColors.errorRed),
                              );
                            }
                          }
                        },
                        icon: Icon(
                            product == null ? Icons.add : Icons.save_outlined),
                        label: Text(
                            product == null ? 'Th�m s?n ph?m' : 'Luu thay d?i'),
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
