import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';

// ─── Data constants matching whiteboard ─────────────────────────────────────

const _kVehicleBrands = ['Isuzu', 'Hino', 'Hyundai', 'Mitsubishi', 'Thaco', 'Dongfeng', 'Khác'];

const _kBodyTypes = [
  ('TL', 'Thùng lửng'),
  ('BQ', 'Bảo ôn / quạt'),
  ('TC', 'Thùng cánh dơi'),
  ('TK', 'Thùng kín'),
  ('BT', 'Ben tự đổ'),
  ('XTR', 'Xi-téc rời'),
];

const _kBodySizes = ['HA', 'A2', 'M', 'S', 'L', 'XL'];

const _kOptions = [
  ('cua_hong', 'Cửa hông'),
  ('san_go', 'Sàn gỗ'),
  ('san_inox', 'Sàn inox'),
  ('den_led', 'Đèn LED thùng'),
  ('khoa_cont', 'Khoá container'),
  ('bung_nang', 'Bửng nâng'),
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
  final _noteCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String? _selectedProductId;
  String? _selectedBrand;
  String? _selectedBodyType;
  String? _selectedBodySize;
  final Set<String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.preselectedProductId;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final isGuest = !ref.read(isAuthenticatedProvider);

    final bool success;
    if (isGuest) {
      success = await ref.read(quotationProvider.notifier).submitGuest(
            phone: _phoneCtrl.text.trim(),
            fullName: _nameCtrl.text.trim().isEmpty
                ? null
                : _nameCtrl.text.trim(),
            productId: _selectedProductId,
            vehicleBrand: _selectedBrand,
            bodyType: _selectedBodyType,
            bodySize: _selectedBodySize,
            lengthCm: double.tryParse(_lengthCtrl.text.trim()),
            widthCm: double.tryParse(_widthCtrl.text.trim()),
            heightCm: double.tryParse(_heightCtrl.text.trim()),
            options: _selectedOptions.isNotEmpty
                ? _selectedOptions.toList()
                : null,
            note: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );
    } else {
      success = await ref.read(quotationProvider.notifier).submit(
            productId: _selectedProductId ?? '',
            vehicleBrand: _selectedBrand!,
            bodyType: _selectedBodyType!,
            bodySize: _selectedBodySize!,
            lengthCm: double.tryParse(_lengthCtrl.text.trim()),
            widthCm: double.tryParse(_widthCtrl.text.trim()),
            heightCm: double.tryParse(_heightCtrl.text.trim()),
            options: _selectedOptions.isNotEmpty
                ? _selectedOptions.toList()
                : null,
            note: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );
    }

    if (!mounted) return;

    if (success) {
      if (isGuest) {
        _showGuestSuccessDialog();
      } else {
        final order = ref.read(quotationProvider).value!;
        _showSuccessDialog(order.orderCode);
      }
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

  void _showGuestSuccessDialog() {
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
              'Đã gửi yêu cầu!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cảm ơn bạn! Nhân viên Quyen Auto sẽ liên hệ '
              'qua số điện thoại bạn đã cung cấp trong thời gian sớm nhất.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
              },
              child: const Text('Về trang chủ'),
            ),
          ),
        ],
      ),
    );
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
    final isGuest = !ref.watch(isAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Yêu cầu báo giá')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guest: phone & name
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.infoBlue.withValues(alpha: 0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline,
                        color: AppColors.infoBlue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vui lòng để lại số điện thoại để nhân viên '
                        'liên hệ tư vấn báo giá cho bạn.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.infoBlue,
                            height: 1.4),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  number: '☎',
                  title: 'Thông tin liên hệ',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại *',
                          hintText: '0901234567',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên (không bắt buộc)',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ① Loại xe
              _SectionCard(
                number: '1',
                title: 'Loại xe',
                trailing: _buildBrandChips(isLoading),
                child: productsAsync.when(
                  data: (products) {
                    final selected = products
                        .where((p) => p.id == _selectedProductId)
                        .firstOrNull;

                    if (selected != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.local_shipping,
                              color: AppColors.primaryOrange, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(selected.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textDark)),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedProductId = null),
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.textGray),
                          ),
                        ]),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedProductId,
                      decoration: InputDecoration(
                        labelText: isGuest
                            ? 'Chọn sản phẩm (không bắt buộc)'
                            : 'Chọn sản phẩm *',
                        prefixIcon: const Icon(Icons.local_shipping_outlined),
                      ),
                      isExpanded: true,
                      items: products
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _selectedProductId = v),
                      validator: isGuest
                          ? null
                          : (v) =>
                              v == null ? 'Vui lòng chọn sản phẩm' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => OutlinedButton.icon(
                    onPressed: () => ref.invalidate(productListProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại danh sách'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ② Loại thùng
              _SectionCard(
                number: '2',
                title: 'Loại thùng',
                child: _buildBodyTypeSelector(isLoading),
              ),

              const SizedBox(height: 16),

              // ③ Size thùng
              _SectionCard(
                number: '3',
                title: 'Size thùng',
                child: _buildBodySizeSelector(isLoading),
              ),

              const SizedBox(height: 16),

              // ④ Kích thước thùng
              _SectionCard(
                number: '4',
                title: 'Kích thước thùng',
                subtitle: 'Dài × Rộng × Cao (cm)',
                child: _buildDimensionInputs(isLoading),
              ),

              const SizedBox(height: 16),

              // ⑤ Option
              _SectionCard(
                number: '5',
                title: 'Option',
                child: _buildOptionsCheckboxes(isLoading),
              ),

              const SizedBox(height: 16),

              // Ghi chú
              _SectionCard(
                number: '✎',
                title: 'Ghi chú thêm',
                child: TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Yêu cầu đặc biệt khác...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 28),

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
                  label: Text(
                      isLoading ? 'Đang gửi...' : 'Gửi yêu cầu báo giá'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Brand chips (under product selector) ─────────────────────────────────

  Widget _buildBrandChips(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        const Text('Hãng xe',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textGray)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kVehicleBrands.map((brand) {
            final selected = _selectedBrand == brand;
            return ChoiceChip(
              label: Text(brand),
              selected: selected,
              onSelected: isLoading
                  ? null
                  : (v) => setState(() => _selectedBrand = v ? brand : null),
              selectedColor: AppColors.primaryOrange.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: selected ? AppColors.primaryOrange : AppColors.textDark,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primaryOrange
                    : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Body type selector ───────────────────────────────────────────────────

  Widget _buildBodyTypeSelector(bool isLoading) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: _kBodyTypes.map((entry) {
        final (code, label) = entry;
        final selected = _selectedBodyType == code;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () => setState(() =>
                  _selectedBodyType = selected ? null : code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryNavy
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? AppColors.primaryNavy
                    : AppColors.borderLight,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? AppColors.textWhite
                        : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected
                        ? AppColors.textWhite.withValues(alpha: 0.8)
                        : AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Body size selector ───────────────────────────────────────────────────

  Widget _buildBodySizeSelector(bool isLoading) {
    return Row(
      children: _kBodySizes.map((size) {
        final selected = _selectedBodySize == size;
        return Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () => setState(() =>
                    _selectedBodySize = selected ? null : size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryOrange
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryOrange
                      : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.textWhite
                        : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Dimension inputs (Dài × Rộng × Cao) ─────────────────────────────────

  Widget _buildDimensionInputs(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: _DimensionField(
            controller: _lengthCtrl,
            label: 'Dài',
            enabled: !isLoading,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('×',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textGray)),
        ),
        Expanded(
          child: _DimensionField(
            controller: _widthCtrl,
            label: 'Rộng',
            enabled: !isLoading,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('×',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textGray)),
        ),
        Expanded(
          child: _DimensionField(
            controller: _heightCtrl,
            label: 'Cao',
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }

  // ─── Option checkboxes ────────────────────────────────────────────────────

  Widget _buildOptionsCheckboxes(bool isLoading) {
    return Column(
      children: [
        for (int i = 0; i < _kOptions.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: _OptionCheckbox(
                    code: _kOptions[i].$1,
                    label: _kOptions[i].$2,
                    checked: _selectedOptions.contains(_kOptions[i].$1),
                    enabled: !isLoading,
                    onChanged: (v) => setState(() {
                      if (v) {
                        _selectedOptions.add(_kOptions[i].$1);
                      } else {
                        _selectedOptions.remove(_kOptions[i].$1);
                      }
                    }),
                  ),
                ),
                if (i + 1 < _kOptions.length)
                  Expanded(
                    child: _OptionCheckbox(
                      code: _kOptions[i + 1].$1,
                      label: _kOptions[i + 1].$2,
                      checked: _selectedOptions.contains(_kOptions[i + 1].$1),
                      enabled: !isLoading,
                      onChanged: (v) => setState(() {
                        if (v) {
                          _selectedOptions.add(_kOptions[i + 1].$1);
                        } else {
                          _selectedOptions.remove(_kOptions[i + 1].$1);
                        }
                      }),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Section Card wrapper ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Dimension text field ───────────────────────────────────────────────────

class _DimensionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const _DimensionField({
    required this.controller,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'cm',
        suffixStyle: const TextStyle(fontSize: 12, color: AppColors.textGray),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ─── Option checkbox tile ───────────────────────────────────────────────────

class _OptionCheckbox extends StatelessWidget {
  final String code;
  final String label;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _OptionCheckbox({
    required this.code,
    required this.label,
    required this.checked,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!checked) : null,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.primaryOrange
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: checked
                    ? AppColors.primaryOrange
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: checked
                ? const Icon(Icons.check, size: 16, color: AppColors.textWhite)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: checked ? AppColors.textDark : AppColors.textGray,
                fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
