import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/product.dart';

// ─── Constants (giống QuotationFormScreen) ────────────────────────────────────

const _kBoxCategories = ['THÙNG ĐÔNG LẠNH-BẢO ÔN', 'THÙNG TẢI KÍN'];
const _kVehicleModels = [
  'ISUZU QMR77HE5 (2.5T)', 'ISUZU QKR270 (1.9T)', 'ISUZU NPR85HE (3.5T)',
  'ISUZU NQR75LE (5T)', 'ISUZU FRR90 (6.2T)', 'ISUZU FSR-N 2026 (7T)',
  'ISUZU FVM1500 (15T)',
  'HINO 300 XZU342 (3.5T)', 'HINO 300 XZU720 (5T)', 'HINO 500 FC9JLSW (6.4T)',
  'HINO 500 FG8JPSW (10T)', 'HINO 500 FG (14T)',
  'HYUNDAI HD35 (1.5T)', 'HYUNDAI HD65 (2.5T)', 'HYUNDAI HD72 (3.5T)',
  'HYUNDAI HD99 (7T)', 'HYUNDAI HD120 (8T)',
  'MITSUBISHI FUSO Canter (3.5T)', 'MITSUBISHI FUSO Fighter (7T)',
  'Loại khác',
];
const _kBoxTypes = ['F2LB', 'F2LC', 'F2LA', 'L', 'S'];
const _kFloorTypes = ['C', 'L', 'U', 'M'];
const _kAcTypes = ['TN', 'Oxy', 'S2'];
const _kPillarTypes = ['NH', 'INOX'];
const _kFloorRequirements = [
  'Nhôm chống trượt',
  'Gỗ chống trượt',
  'Inox chống trượt',
  'Thép mạ kẽm',
];
const _kPanelCodes = [
  'E1-F','E1-C','E2','A1','A2','E3','RPB','CPB','RLL','CLL','S-CS','T-CS',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class StaffCreateQuotationScreen extends ConsumerStatefulWidget {
  const StaffCreateQuotationScreen({super.key});

  @override
  ConsumerState<StaffCreateQuotationScreen> createState() =>
      _StaffCreateQuotationScreenState();
}

class _StaffCreateQuotationScreenState
    extends ConsumerState<StaffCreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Thông tin KH ────────────────────────────────────────────────────────
  int? _selectedCustomerId;
  String? _selectedCustomerName;
  final _customerSearchCtrl = TextEditingController();

  // ─── Sản phẩm ────────────────────────────────────────────────────────────
  bool _isNewProduct = false; // true = "Sản phẩm mới"
  final _newProductDescCtrl = TextEditingController();
  String? _selectedProductId;
  String _boxCategory = _kBoxCategories[0];
  String? _vehicleModel;

  // ─── Thông số BG ─────────────────────────────────────────────────────────
  final _quantityCtrl = TextEditingController(text: '1');
  final _chassisWidthCtrl = TextEditingController();
  final _boxCodeCtrl = TextEditingController();
  String? _boxType;
  String? _pillarType;
  String? _floorType;
  String? _acType;
  final _acModelCtrl = TextEditingController();
  bool _innerWallInsulated = false;
  final _outerLCtrl = TextEditingController();
  final _outerWCtrl = TextEditingController();
  final _outerHCtrl = TextEditingController();
  final _innerLCtrl = TextEditingController();
  final _innerWCtrl = TextEditingController();
  final _innerHCtrl = TextEditingController();

  // ─── Phụ kiện ────────────────────────────────────────────────────────────
  String? _floorRequirement;
  bool _sideLight = false;
  final _sideLightQtyCtrl = TextEditingController(text: '0');
  bool _ladder = false;
  final _ladderQtyCtrl = TextEditingController(text: '1');

  // ─── Panel / Foam ─────────────────────────────────────────────────────────
  String? _panelFloor, _panelFront, _panelSide, _panelRoof, _panelDoor;
  final _foamFloorCtrl = TextEditingController(text: '60');
  final _foamFrontCtrl = TextEditingController(text: '60');
  final _foamSideCtrl = TextEditingController(text: '60');
  final _foamRoofCtrl = TextEditingController(text: '75');
  final _foamDoorCtrl = TextEditingController(text: '60');

  // ─── Ghi chú ─────────────────────────────────────────────────────────────
  final _noteCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _customerSearchCtrl, _newProductDescCtrl, _quantityCtrl, _chassisWidthCtrl,
      _boxCodeCtrl, _acModelCtrl,
      _outerLCtrl, _outerWCtrl, _outerHCtrl,
      _innerLCtrl, _innerWCtrl, _innerHCtrl,
      _sideLightQtyCtrl, _ladderQtyCtrl,
      _foamFloorCtrl, _foamFrontCtrl, _foamSideCtrl, _foamRoofCtrl, _foamDoorCtrl,
      _noteCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Build specifications JSON ────────────────────────────────────────────

  Map<String, dynamic> _buildSpecs() => {
        'boxCategory': _boxCategory,
        'dimensions': {
          'outer': {
            'length': int.tryParse(_outerLCtrl.text),
            'width': int.tryParse(_outerWCtrl.text),
            'height': int.tryParse(_outerHCtrl.text),
          },
          'inner': {
            'length': int.tryParse(_innerLCtrl.text),
            'width': int.tryParse(_innerWCtrl.text),
            'height': int.tryParse(_innerHCtrl.text),
          },
        },
        'pillarType': _pillarType,
        'floor': {'type': _floorType, 'requirement': _floorRequirement},
        'sideLight': {
          'enabled': _sideLight,
          'qty': _sideLight ? (int.tryParse(_sideLightQtyCtrl.text) ?? 0) : 0,
        },
        'ladder': {
          'enabled': _ladder,
          'qty': _ladder ? (int.tryParse(_ladderQtyCtrl.text) ?? 1) : 0,
        },
        'panel': {
          'floor': _panelFloor,
          'front': _panelFront,
          'side': _panelSide,
          'roof': _panelRoof,
          'door': _panelDoor,
        },
        'foam': {
          'floor': int.tryParse(_foamFloorCtrl.text) ?? 60,
          'front': int.tryParse(_foamFrontCtrl.text) ?? 60,
          'side': int.tryParse(_foamSideCtrl.text) ?? 60,
          'roof': int.tryParse(_foamRoofCtrl.text) ?? 75,
          'door': int.tryParse(_foamDoorCtrl.text) ?? 60,
        },
      };

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng chọn khách hàng'),
        backgroundColor: AppColors.errorRed,
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      final data = <String, dynamic>{
        'customerId': _selectedCustomerId,
        'isNewProductRequest': _isNewProduct,
        if (_isNewProduct)
          'newProductDescription': _newProductDescCtrl.text.trim(),
        if (!_isNewProduct && _selectedProductId != null)
          'productId': int.tryParse(_selectedProductId!),
        if (_vehicleModel != null) 'vehicleModel': _vehicleModel,
        'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
        if (_chassisWidthCtrl.text.isNotEmpty)
          'chassisWidth': int.tryParse(_chassisWidthCtrl.text),
        if (_boxCodeCtrl.text.trim().isNotEmpty)
          'boxCode': _boxCodeCtrl.text.trim(),
        if (_boxType != null) 'boxType': _boxType,
        if (_acType != null) 'acType': _acType,
        if (_acModelCtrl.text.trim().isNotEmpty)
          'acModel': _acModelCtrl.text.trim(),
        'innerWallInsulated': _innerWallInsulated,
        'specifications': jsonEncode(_buildSpecs()),
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
      };

      final quotation =
          await ref.read(staffActionsProvider.notifier).staffCreateQuotation(data);

      if (!mounted) return;

      // Hỏi NV có muốn gửi duyệt ngay không
      _showCreatedDialog(quotation.id.toString());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: AppColors.errorRed,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showCreatedDialog(String quotationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đã tạo báo giá!'),
        content: const Text(
          'Báo giá đã được lưu (DRAFT).\n\nBạn có muốn gửi Manager duyệt ngay không?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Để sau'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(staffActionsProvider.notifier)
                    .submitForApproval(quotationId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã gửi Manager duyệt!'),
                    backgroundColor: AppColors.successGreen,
                  ));
                  Navigator.pop(context);
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
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Gửi duyệt ngay'),
          ),
        ],
      ),
    );
  }

  // ─── Customer picker ──────────────────────────────────────────────────────

  Future<void> _pickCustomer() async {
    // TODO: navigate to customer search screen — tạm thời dùng dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CustomerPickerDialog(),
    );
    if (result != null) {
      setState(() {
        _selectedCustomerId = result['id'] as int;
        _selectedCustomerName = result['name'] as String;
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tạo Báo Giá'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryOrange),
                  )
                : const Icon(Icons.save_outlined,
                    color: AppColors.primaryOrange),
            label: const Text('Lưu BG',
                style: TextStyle(color: AppColors.primaryOrange)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // ── Chọn KH ────────────────────────────────────────────────────
            _Section(
              title: 'Khách hàng',
              subtitle: 'Chọn KH từ danh sách',
              child: _buildCustomerSection(),
            ),

            // ── Sản phẩm ────────────────────────────────────────────────────
            _Section(
              title: 'Sản phẩm',
              subtitle: 'Chọn SP có sẵn hoặc yêu cầu SP mới',
              child: _buildProductSection(productsAsync),
            ),

            // ── Thông số kỹ thuật ───────────────────────────────────────────
            if (!_isNewProduct) ...[
              _Section(
                title: 'Thông số kỹ thuật',
                subtitle: 'Kích thước, loại thùng, máy lạnh',
                child: _buildSpecsSection(),
              ),
              _Section(
                title: 'Phụ kiện',
                subtitle: 'Sàn, cửa, đèn, thang leo',
                child: _buildAccessoriesSection(),
              ),
              _Section(
                title: 'Panel & Foam',
                subtitle: 'Thông số vật liệu',
                child: _buildPanelFoamSection(),
              ),
            ],

            // ── Ghi chú ─────────────────────────────────────────────────────
            _Section(
              title: 'Ghi chú',
              subtitle: 'Thông tin thêm cho BG này',
              child: TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú, yêu cầu đặc biệt...',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: const Text('Lưu Báo Giá (DRAFT)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section builders ─────────────────────────────────────────────────────

  Widget _buildCustomerSection() {
    if (_selectedCustomerId != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primaryOrange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person, color: AppColors.primaryOrange, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedCustomerName ?? 'KH #$_selectedCustomerId',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => setState(() {
                _selectedCustomerId = null;
                _selectedCustomerName = null;
              }),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _pickCustomer,
      icon: const Icon(Icons.person_search_outlined),
      label: const Text('Chọn khách hàng *'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        foregroundColor: AppColors.primaryOrange,
        side: const BorderSide(color: AppColors.primaryOrange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProductSection(AsyncValue<List<Product>> productsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle: SP có sẵn / SP mới
        Row(
          children: [
            Expanded(
              child: _ToggleOption(
                label: 'SP có sẵn',
                selected: !_isNewProduct,
                icon: Icons.inventory_2_outlined,
                onTap: () => setState(() => _isNewProduct = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleOption(
                label: 'Sản phẩm mới ✦',
                selected: _isNewProduct,
                icon: Icons.add_circle_outline,
                onTap: () => setState(() => _isNewProduct = true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_isNewProduct) ...[
          // Mô tả sản phẩm mới
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.warningAmber.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.warningAmber, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manager sẽ tạo giá cho sản phẩm mới này.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.warningAmber),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newProductDescCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Mô tả yêu cầu sản phẩm *',
              hintText: 'Loại xe, tải trọng, yêu cầu đặc biệt...',
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (_isNewProduct && (v == null || v.trim().isEmpty)) {
                return 'Vui lòng mô tả yêu cầu sản phẩm mới';
              }
              return null;
            },
          ),
        ] else ...[
          // Loại thùng
          _label('Loại thùng'),
          const SizedBox(height: 8),
          Row(
            children: _kBoxCategories.map((cat) {
              final sel = _boxCategory == cat;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _boxCategory = cat),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: cat == _kBoxCategories[0] ? 6 : 0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryOrange
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel
                              ? AppColors.primaryOrange
                              : AppColors.borderLight),
                    ),
                    child: Text(
                      cat,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textDark),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            data: (products) {
              final filtered =
                  products.where((p) => p.id == _selectedProductId);
              final selected = filtered.isEmpty ? null : filtered.first;
              if (selected != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(selected.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () =>
                            setState(() => _selectedProductId = null),
                      ),
                    ],
                  ),
                );
              }
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'Chọn sản phẩm *',
                    prefixIcon: Icon(Icons.inventory_2_outlined)),
                isExpanded: true,
                items: products
                    .map((p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProductId = v),
                validator: (v) {
                  if (!_isNewProduct && v == null) {
                    return 'Vui lòng chọn sản phẩm';
                  }
                  return null;
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => OutlinedButton.icon(
              onPressed: () => ref.invalidate(productListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại xe
        _label('Kiểu loại xe *'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.directions_car_outlined),
              labelText: 'Chọn kiểu loại xe *'),
          isExpanded: true,
          items: _kVehicleModels
              .map((m) => DropdownMenuItem<String>(
                  value: m,
                  child: Text(m, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _vehicleModel = v),
          validator: (v) =>
              !_isNewProduct && v == null ? 'Vui lòng chọn kiểu xe' : null,
        ),

        const SizedBox(height: 12),

        // Số lượng + Rộng chassis
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Số lượng'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _chassisWidthCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    const InputDecoration(labelText: 'Rộng chassis (mm)'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mã thùng + Loại
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _boxCodeCtrl,
                decoration:
                    const InputDecoration(hintText: 'Mã thùng (VD: 001/26)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại thùng'),
                isExpanded: true,
                items: _kBoxTypes
                    .map((t) => DropdownMenuItem<String>(
                        value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _boxType = v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Kích thước phủ bì
        _label('Kích thước phủ bì (mm)'),
        const SizedBox(height: 6),
        _dimRow([_outerLCtrl, _outerWCtrl, _outerHCtrl],
            ['Dài', 'Rộng', 'Cao']),

        const SizedBox(height: 12),

        // Kích thước lọt lòng
        _label('Kích thước lọt lòng (mm)'),
        const SizedBox(height: 6),
        _dimRow([_innerLCtrl, _innerWCtrl, _innerHCtrl],
            ['Dài', 'Rộng', 'Cao']),

        const SizedBox(height: 12),

        // Loại trụ + Loại sàn
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại trụ'),
                isExpanded: true,
                items: _kPillarTypes
                    .map((t) => DropdownMenuItem<String>(
                        value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _pillarType = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại sàn'),
                isExpanded: true,
                items: _kFloorTypes
                    .map((t) => DropdownMenuItem<String>(
                        value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _floorType = v),
              ),
            ),
          ],
        ),

        if (_boxCategory == _kBoxCategories[0]) ...[
          const SizedBox(height: 12),
          _label('Máy lạnh'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Loại ML'),
                  isExpanded: true,
                  items: _kAcTypes
                      .map((t) => DropdownMenuItem<String>(
                          value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _acType = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _acModelCtrl,
                  decoration: const InputDecoration(labelText: 'Model ML'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAccessoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Yêu cầu sàn'),
          isExpanded: true,
          items: _kFloorRequirements
              .map((r) => DropdownMenuItem<String>(
                  value: r,
                  child: Text(r, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _floorRequirement = v),
        ),
        _cbWithQty(
          'Đèn hông',
          _sideLight,
          _sideLightQtyCtrl,
          (v) => setState(() => _sideLight = v ?? false),
        ),
        _cbWithQty(
          'Thang leo',
          _ladder,
          _ladderQtyCtrl,
          (v) => setState(() => _ladder = v ?? false),
        ),
      ],
    );
  }

  Widget _buildPanelFoamSection() {
    const surfaces = ['Sàn', 'Đầu', 'Hông', 'Nóc', 'Cửa'];
    final panelVals = [
      _panelFloor, _panelFront, _panelSide, _panelRoof, _panelDoor
    ];
    final panelSetters = <void Function(String?)>[
      (v) => setState(() => _panelFloor = v),
      (v) => setState(() => _panelFront = v),
      (v) => setState(() => _panelSide = v),
      (v) => setState(() => _panelRoof = v),
      (v) => setState(() => _panelDoor = v),
    ];
    final foamCtrls = [
      _foamFloorCtrl, _foamFrontCtrl, _foamSideCtrl, _foamRoofCtrl, _foamDoorCtrl
    ];

    return Column(
      children: [
        for (int i = 0; i < surfaces.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(surfaces[i],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: panelVals[i],
                    isDense: true,
                    decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        hintText: 'Panel'),
                    isExpanded: true,
                    items: _kPanelCodes
                        .map((c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: panelSetters[i],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 74,
                  child: TextFormField(
                    controller: foamCtrls[i],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      suffixText: 'mm',
                      suffixStyle: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _label(String text) => Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
        ],
      );

  Widget _dimRow(
      List<TextEditingController> ctrls, List<String> labels) {
    return Row(
      children: List.generate(ctrls.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < ctrls.length - 1 ? 8 : 0),
            child: TextFormField(
              controller: ctrls[i],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: labels[i]),
            ),
          ),
        );
      }),
    );
  }

  Widget _cbWithQty(String label, bool value,
      TextEditingController qtyCtrl, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(label, style: const TextStyle(fontSize: 14)),
            value: value,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primaryOrange,
          ),
        ),
        if (value)
          SizedBox(
            width: 72,
            child: TextFormField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  const InputDecoration(labelText: 'SL', isDense: true),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

// ─── Toggle option widget ─────────────────────────────────────────────────────

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? AppColors.primaryOrange
                  : AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textGray),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Customer Picker Dialog ───────────────────────────────────────────────────

class _CustomerPickerDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CustomerPickerDialog> createState() =>
      _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends ConsumerState<_CustomerPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tái sử dụng staffCustomers provider
    final customersAsync = ref.watch(_customerListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chọn Khách Hàng',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Tìm tên, SĐT...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 350,
            child: customersAsync.when(
              data: (customers) {
                final filtered = _query.isEmpty
                    ? customers
                    : customers.where((c) {
                        final name =
                            (c['fullName'] as String? ?? '').toLowerCase();
                        final phone =
                            (c['phone'] as String? ?? '').toLowerCase();
                        return name.contains(_query) ||
                            phone.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('Không tìm thấy khách hàng'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryOrange
                            .withValues(alpha: 0.12),
                        child: Text(
                          (c['fullName'] as String? ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(c['fullName'] as String? ?? '—',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(c['phone'] as String? ?? '',
                          style: const TextStyle(fontSize: 12)),
                      onTap: () => Navigator.pop(context, {
                        'id': c['id'] as int,
                        'name': c['fullName'] as String? ?? '?',
                      }),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.errorRed),
                    const SizedBox(height: 8),
                    Text('$e',
                        style:
                            const TextStyle(color: AppColors.errorRed)),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(_customerListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer list provider (local) ──────────────────────────────────────────

final _customerListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final api = ref.watch(apiServiceProvider);
      final res = await api.get<List<Map<String, dynamic>>>(
        'staff/customers',
        queryParams: {'page': 0, 'size': 200},
        fromData: (json) {
          final List<dynamic> list = json is List
              ? json
              : (json as Map<String, dynamic>)['content'] as List<dynamic>? ??
                  [];
          return list.cast<Map<String, dynamic>>();
        },
      );
      return res.data ?? [];
    });

// ─── Section widget ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _Section(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGray)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
