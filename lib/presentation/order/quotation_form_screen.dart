import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';

const _kWeightRanges = [
  'Dưới 3 tấn',
  '3–6 tấn',
  '6–10 tấn',
  'Trên 10 tấn',
];

const _kCargoHints = [
  'Thực phẩm',
  'Thuốc / Dược phẩm',
  'Điện tử',
  'Vật liệu xây dựng',
  'Hóa chất',
  'Hàng đông lạnh',
];

class QuotationFormScreen extends ConsumerStatefulWidget {
  final String? preselectedProductId;
  const QuotationFormScreen({super.key, this.preselectedProductId});

  @override
  ConsumerState<QuotationFormScreen> createState() =>
      _QuotationFormScreenState();
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cargoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _selectedProductId;
  String? _selectedWeight;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.preselectedProductId;
  }

  @override
  void dispose() {
    _cargoCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(quotationProvider.notifier).submit(
          productId: _selectedProductId ?? '',
          truckType: _selectedWeight!,
          truckLength: 0,
          requirements: _cargoCtrl.text.trim(),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      final order = ref.read(quotationProvider).value!;
      _showSuccessDialog(order.orderCode);
    } else {
      final err = ref.read(quotationProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err?.toString().replaceAll('Exception:', '').trim() ??
                'Không thể gửi yêu cầu. Vui lòng thử lại.',
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.successGreen, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gửi yêu cầu thành công!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã đơn: $orderCode\nChúng tôi sẽ liên hệ sớm để xác nhận báo giá.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textGray, height: 1.5),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
                ref.read(homeTabIndexProvider.notifier).state = 2;
              },
              child: const Text('Xem đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final isLoading = ref.watch(quotationProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Yêu cầu báo giá')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product selector
              _sectionHeader('Sản phẩm'),
              const SizedBox(height: 12),
              productsAsync.when(
                data: (products) {
                  final selected = products
                      .where((p) => p.id == _selectedProductId)
                      .firstOrNull;

                  if (selected != null) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryOrange
                                .withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.local_shipping,
                            color: AppColors.primaryOrange, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selected.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textDark)),
                              if (selected.truckType != null)
                                Text(selected.truckType!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGray)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              setState(() => _selectedProductId = null),
                        ),
                      ]),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Chọn sản phẩm *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    isExpanded: true,
                    items: products
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child:
                                  Text(p.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() => _selectedProductId = v),
                    validator: (v) => v == null ? 'Vui lòng chọn sản phẩm' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => OutlinedButton.icon(
                  onPressed: () => ref.invalidate(productListProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại danh sách'),
                ),
              ),

              const SizedBox(height: 24),

              // Weight range
              _sectionHeader('Tải trọng'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedWeight,
                decoration: const InputDecoration(
                  labelText: 'Chọn tải trọng *',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
                isExpanded: true,
                items: _kWeightRanges
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (v) => setState(() => _selectedWeight = v),
                validator: (v) =>
                    v == null ? 'Vui lòng chọn tải trọng' : null,
              ),

              const SizedBox(height: 24),

              // Cargo type
              _sectionHeader('Loại hàng hóa'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cargoCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Loại hàng hóa sẽ chở *',
                  hintText: 'VD: thực phẩm, thuốc, điện tử...',
                  prefixIcon: const Icon(Icons.category_outlined),
                  helperText: _kCargoHints.join(' · '),
                  helperMaxLines: 2,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập loại hàng hóa';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Note
              _sectionHeader('Ghi chú thêm'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 500,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  hintText: 'Yêu cầu đặc biệt, kích thước thùng...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.send_outlined),
                  label:
                      Text(isLoading ? 'Đang gửi...' : 'Gửi yêu cầu báo giá'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
    ]);
  }
}
