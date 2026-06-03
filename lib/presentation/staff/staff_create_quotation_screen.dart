import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/product.dart';

// ─── Constants (giống QuotationFormScreen) ────────────────────────────────────

const _kBoxCategories = ['THÙNG ĐÔNG LẠNH-BẢO ÔN', 'THÙNG TẢI KÍN'];
const _kVehicleModels = [
  'ISUZU QMR77HE5 (2.5T)',
  'ISUZU QKR270 (1.9T)',
  'ISUZU NPR85HE (3.5T)',
  'ISUZU NQR75LE (5T)',
  'ISUZU FRR90 (6.2T)',
  'ISUZU FSR-N 2026 (7T)',
  'ISUZU FVM1500 (15T)',
  'HINO 300 XZU342 (3.5T)',
  'HINO 300 XZU720 (5T)',
  'HINO 500 FC9JLSW (6.4T)',
  'HINO 500 FG8JPSW (10T)',
  'HINO 500 FG (14T)',
  'HYUNDAI HD35 (1.5T)',
  'HYUNDAI HD65 (2.5T)',
  'HYUNDAI HD72 (3.5T)',
  'HYUNDAI HD99 (7T)',
  'HYUNDAI HD120 (8T)',
  'MITSUBISHI FUSO Canter (3.5T)',
  'MITSUBISHI FUSO Fighter (7T)',
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
  'E1-F',
  'E1-C',
  'E2',
  'A1',
  'A2',
  'E3',
  'RPB',
  'CPB',
  'RLL',
  'CLL',
  'S-CS',
  'T-CS',
];

// ─── Vehicle spec data (từ file PDF tờ rơi Quyen Auto) ───────────────────────

class _VehicleSpec {
  final int outerL, outerW, outerH;
  final int innerL, innerW, innerH;
  final int chassisW;
  final int foamFloor, foamFront, foamSide, foamRoof, foamDoor;
  const _VehicleSpec({
    required this.outerL,
    required this.outerW,
    required this.outerH,
    required this.innerL,
    required this.innerW,
    required this.innerH,
    required this.chassisW,
    required this.foamFloor,
    required this.foamFront,
    required this.foamSide,
    required this.foamRoof,
    required this.foamDoor,
  });
}

/// Thông số thùng đông lạnh chuẩn theo từng xe nền (từ tờ rơi kỹ thuật Quyen Auto).
/// Mỗi entry: outer = kích thước phủ bì, inner = kích thước lọt lòng (mm).
const _kVehicleSpecs = <String, _VehicleSpec>{
  // ── ISUZU QKR / QMR ────────────────────────────────────────────────────────
  'ISUZU QKR270 (1.9T)': _VehicleSpec(
    outerL: 3700,
    outerW: 1950,
    outerH: 1950,
    innerL: 3520,
    innerW: 1810,
    innerH: 1780,
    chassisW: 1820,
    foamFloor: 80,
    foamFront: 65,
    foamSide: 65,
    foamRoof: 75,
    foamDoor: 65,
  ),
  'ISUZU QMR77HE5 (2.5T)': _VehicleSpec(
    outerL: 4450,
    outerW: 1950,
    outerH: 1950,
    innerL: 4270,
    innerW: 1810,
    innerH: 1780,
    chassisW: 1820,
    foamFloor: 80,
    foamFront: 65,
    foamSide: 65,
    foamRoof: 75,
    foamDoor: 65,
  ),
  // ── ISUZU N-Series ──────────────────────────────────────────────────────────
  'ISUZU NPR85HE (3.5T)': _VehicleSpec(
    outerL: 5200,
    outerW: 2200,
    outerH: 2350,
    innerL: 5020,
    innerW: 2060,
    innerH: 2165,
    chassisW: 2050,
    foamFloor: 95,
    foamFront: 63,
    foamSide: 63,
    foamRoof: 78,
    foamDoor: 63,
  ),
  'ISUZU NQR75LE (5T)': _VehicleSpec(
    outerL: 5750,
    outerW: 2200,
    outerH: 2350,
    innerL: 5570,
    innerW: 2060,
    innerH: 2170,
    chassisW: 2050,
    foamFloor: 95,
    foamFront: 63,
    foamSide: 63,
    foamRoof: 78,
    foamDoor: 63,
  ),
  // ── HINO 300 ────────────────────────────────────────────────────────────────
  'HINO 300 XZU342 (3.5T)': _VehicleSpec(
    outerL: 4600,
    outerW: 1860,
    outerH: 2000,
    innerL: 4420,
    innerW: 1710,
    innerH: 1840,
    chassisW: 1695,
    foamFloor: 80,
    foamFront: 65,
    foamSide: 65,
    foamRoof: 80,
    foamDoor: 65,
  ),
  'HINO 300 XZU720 (5T)': _VehicleSpec(
    outerL: 5250,
    outerW: 2150,
    outerH: 2080,
    innerL: 5070,
    innerW: 2000,
    innerH: 1895,
    chassisW: 1995,
    foamFloor: 85,
    foamFront: 65,
    foamSide: 65,
    foamRoof: 80,
    foamDoor: 65,
  ),
};

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
  bool _isGuestCustomer = false;
  // KH có tài khoản
  int? _selectedCustomerId;
  String? _selectedCustomerName;
  final _customerSearchCtrl = TextEditingController();
  // KH vãng lai (chưa đăng ký)
  final _guestNameCtrl = TextEditingController();
  final _guestPhoneCtrl = TextEditingController();

  // ─── Sản phẩm ────────────────────────────────────────────────────────────
  bool _isNewProduct = false; // true = "Sản phẩm mới"
  final _newProductDescCtrl = TextEditingController();
  String? _selectedTemplateId;
  String? _selectedProductId;
  String _boxCategory = _kBoxCategories[0];
  String? _vehicleModel;
  double _templateBasePrice = 0;

  // ─── Thông số BG ─────────────────────────────────────────────────────────
  final _quantityCtrl = TextEditingController(text: '1');
  final _chassisWidthCtrl = TextEditingController();
  final _boxCodeCtrl = TextEditingController();
  String? _boxType;
  String? _pillarType;
  String? _floorType;
  String? _acType;
  final _acModelCtrl = TextEditingController();
  final bool _innerWallInsulated = false;
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
  final List<_SelectedQuotationOption> _selectedQuotationOptions = [];

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

  double get _optionTotal => _selectedQuotationOptions.fold<double>(
    0,
    (sum, item) => sum + item.totalPrice,
  );

  double get _estimatedTotal => _templateBasePrice + _optionTotal;

  @override
  void dispose() {
    for (final c in [
      _customerSearchCtrl,
      _guestNameCtrl,
      _guestPhoneCtrl,
      _newProductDescCtrl,
      _quantityCtrl,
      _chassisWidthCtrl,
      _boxCodeCtrl,
      _acModelCtrl,
      _outerLCtrl,
      _outerWCtrl,
      _outerHCtrl,
      _innerLCtrl,
      _innerWCtrl,
      _innerHCtrl,
      _sideLightQtyCtrl,
      _ladderQtyCtrl,
      _foamFloorCtrl,
      _foamFrontCtrl,
      _foamSideCtrl,
      _foamRoofCtrl,
      _foamDoorCtrl,
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
    if (!_isGuestCustomer && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khách hàng'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final data = <String, dynamic>{
        if (!_isGuestCustomer) 'customerId': _selectedCustomerId,
        if (_isGuestCustomer) 'guestName': _guestNameCtrl.text.trim(),
        if (_isGuestCustomer) 'guestPhone': _guestPhoneCtrl.text.trim(),
        'isNewProductRequest': _isNewProduct,
        if (_isNewProduct)
          'newProductDescription': _newProductDescCtrl.text.trim(),
        if (_selectedTemplateId != null)
          'templateId': int.tryParse(_selectedTemplateId!),
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
        'selectedOptions': _selectedQuotationOptions
            .map((option) => option.toPayload())
            .toList(),
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
      };

      final quotation = await ref
          .read(staffActionsProvider.notifier)
          .staffCreateQuotation(data);

      if (!mounted) return;

      // Hỏi NV có muốn gửi duyệt ngay không
      _showCreatedDialog(quotation.id.toString());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.errorRed),
      );
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã gửi Manager duyệt!'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
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

  // ─── Vehicle spec auto-fill ───────────────────────────────────────────────

  void _autoFillSpecs(String? model) {
    setState(() => _vehicleModel = model);
    if (model == null) return;
    final spec = _kVehicleSpecs[model];
    if (spec == null) return; // model không có data → giữ nguyên
    _outerLCtrl.text = spec.outerL.toString();
    _outerWCtrl.text = spec.outerW.toString();
    _outerHCtrl.text = spec.outerH.toString();
    _innerLCtrl.text = spec.innerL.toString();
    _innerWCtrl.text = spec.innerW.toString();
    _innerHCtrl.text = spec.innerH.toString();
    _chassisWidthCtrl.text = spec.chassisW.toString();
    _foamFloorCtrl.text = spec.foamFloor.toString();
    _foamFrontCtrl.text = spec.foamFront.toString();
    _foamSideCtrl.text = spec.foamSide.toString();
    _foamRoofCtrl.text = spec.foamRoof.toString();
    _foamDoorCtrl.text = spec.foamDoor.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã điền thông số tự động cho $model'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.successGreen,
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

  void _applyTemplate(QuotationTemplateModel template) {
    setState(() {
      _selectedTemplateId = template.id;
      _templateBasePrice = template.basePrice;
      _isNewProduct = false;
      _selectedProductId = template.productId;
      _vehicleModel = template.vehicleModel ?? _vehicleModel;
      if (template.chassisWidth != null) {
        _chassisWidthCtrl.text = template.chassisWidth.toString();
      }
      _boxType = template.boxType ?? _boxType;
      _acType = template.acType ?? _acType;
      _acModelCtrl.text = template.acModel ?? _acModelCtrl.text;

      final specsText = template.specifications;
      if (specsText != null && specsText.trim().isNotEmpty) {
        try {
          final specs = jsonDecode(specsText) as Map<String, dynamic>;
          final dimensions = specs['dimensions'] as Map<String, dynamic>?;
          final outer = dimensions?['outer'] as Map<String, dynamic>?;
          final inner = dimensions?['inner'] as Map<String, dynamic>?;
          _outerLCtrl.text = _stringValue(outer?['length']);
          _outerWCtrl.text = _stringValue(outer?['width']);
          _outerHCtrl.text = _stringValue(outer?['height']);
          _innerLCtrl.text = _stringValue(inner?['length']);
          _innerWCtrl.text = _stringValue(inner?['width']);
          _innerHCtrl.text = _stringValue(inner?['height']);

          final foam = specs['foam'] as Map<String, dynamic>?;
          _foamFloorCtrl.text = _stringValue(
            foam?['floor'],
            _foamFloorCtrl.text,
          );
          _foamFrontCtrl.text = _stringValue(
            foam?['front'],
            _foamFrontCtrl.text,
          );
          _foamSideCtrl.text = _stringValue(foam?['side'], _foamSideCtrl.text);
          _foamRoofCtrl.text = _stringValue(foam?['roof'], _foamRoofCtrl.text);
          _foamDoorCtrl.text = _stringValue(foam?['door'], _foamDoorCtrl.text);

          final panel = specs['panel'] as Map<String, dynamic>?;
          _panelFloor = panel?['floor'] as String? ?? _panelFloor;
          _panelFront = panel?['front'] as String? ?? _panelFront;
          _panelSide = panel?['side'] as String? ?? _panelSide;
          _panelRoof = panel?['roof'] as String? ?? _panelRoof;
          _panelDoor = panel?['door'] as String? ?? _panelDoor;
        } catch (_) {
          // Mẫu vẫn dùng được nếu JSON thông số chưa đúng; staff chỉnh tay tiếp.
        }
      }
    });
  }

  String _stringValue(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final templatesAsync = ref.watch(activeQuotationTemplateListProvider);
    final optionsAsync = ref.watch(activeQuotationOptionListProvider);

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
                      strokeWidth: 2,
                      color: AppColors.primaryOrange,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                    color: AppColors.primaryOrange,
                  ),
            label: const Text(
              'Lưu BG',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
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
              subtitle: 'KH có tài khoản hoặc khách vãng lai',
              child: _buildCustomerSection(),
            ),

            // ── Sản phẩm ────────────────────────────────────────────────────
            _Section(
              title: 'Sản phẩm',
              subtitle: 'Chọn SP có sẵn hoặc yêu cầu SP mới',
              child: _buildProductSection(productsAsync, templatesAsync),
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
                title: 'Option báo giá',
                subtitle: 'Chọn theo vị trí, tự cộng giá tạm tính',
                child: _buildOptionSelectionSection(optionsAsync),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'Lưu Báo Giá (DRAFT)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section builders ─────────────────────────────────────────────────────

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle: KH có sẵn / Khách vãng lai
        Row(
          children: [
            Expanded(
              child: _ToggleOption(
                label: 'KH có sẵn',
                selected: !_isGuestCustomer,
                icon: Icons.person_search_outlined,
                onTap: () => setState(() => _isGuestCustomer = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleOption(
                label: 'Khách vãng lai',
                selected: _isGuestCustomer,
                icon: Icons.person_add_outlined,
                onTap: () => setState(() => _isGuestCustomer = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (!_isGuestCustomer) ...[
          // ── KH có tài khoản ────────────────────────────────────────────────
          if (_selectedCustomerId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: AppColors.primaryOrange,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedCustomerName ?? 'KH #$_selectedCustomerId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
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
            )
          else
            OutlinedButton.icon(
              onPressed: _pickCustomer,
              icon: const Icon(Icons.person_search_outlined),
              label: const Text('Chọn khách hàng *'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(color: AppColors.primaryOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ] else ...[
          // ── Khách vãng lai ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryNavy.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryNavy,
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Khách chưa có tài khoản — nhập tên và SĐT để lưu vào báo giá.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _guestNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Tên khách hàng *',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                _isGuestCustomer && (v == null || v.trim().isEmpty)
                ? 'Vui lòng nhập tên khách hàng'
                : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _guestPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductSection(
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<List<QuotationTemplateModel>> templatesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle: SP có sẵn / SP mới
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Mẫu báo giá'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTemplateId,
                  decoration: const InputDecoration(
                    labelText: 'Chọn mẫu để tự điền thông số',
                    prefixIcon: Icon(Icons.fact_check_outlined),
                  ),
                  isExpanded: true,
                  items: templates
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(
                            [
                              t.name,
                              if (t.productName != null) t.productName,
                            ].join(' - '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final selected = templates.where((t) => t.id == value);
                    if (selected.isNotEmpty) _applyTemplate(selected.first);
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (_, _) => const SizedBox.shrink(),
        ),
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
                onTap: () => setState(() {
                  _isNewProduct = true;
                  _selectedTemplateId = null;
                }),
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
                color: AppColors.warningAmber.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warningAmber,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manager sẽ tạo giá cho sản phẩm mới này.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warningAmber,
                    ),
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
                      right: cat == _kBoxCategories[0] ? 6 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryOrange
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      cat,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            data: (products) {
              final filtered = products.where(
                (p) => p.id == _selectedProductId,
              );
              final selected = filtered.isEmpty ? null : filtered.first;
              if (selected != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selected.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
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
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                isExpanded: true,
                items: products
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
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
          initialValue: _kVehicleModels.contains(_vehicleModel)
              ? _vehicleModel
              : null,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.directions_car_outlined),
            labelText: 'Chọn kiểu loại xe *',
          ),
          isExpanded: true,
          items: _kVehicleModels
              .map(
                (m) => DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (_kVehicleSpecs.containsKey(m))
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.auto_fix_high,
                            size: 13,
                            color: AppColors.successGreen,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: _autoFillSpecs,
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
                decoration: const InputDecoration(
                  labelText: 'Rộng chassis (mm)',
                ),
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
                decoration: const InputDecoration(
                  hintText: 'Mã thùng (VD: 001/26)',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại thùng'),
                isExpanded: true,
                items: _kBoxTypes
                    .map(
                      (t) => DropdownMenuItem<String>(value: t, child: Text(t)),
                    )
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
        _dimRow(
          [_outerLCtrl, _outerWCtrl, _outerHCtrl],
          ['Dài', 'Rộng', 'Cao'],
        ),

        const SizedBox(height: 12),

        // Kích thước lọt lòng
        _label('Kích thước lọt lòng (mm)'),
        const SizedBox(height: 6),
        _dimRow(
          [_innerLCtrl, _innerWCtrl, _innerHCtrl],
          ['Dài', 'Rộng', 'Cao'],
        ),

        const SizedBox(height: 12),

        // Loại trụ + Loại sàn
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại trụ'),
                isExpanded: true,
                items: _kPillarTypes
                    .map(
                      (t) => DropdownMenuItem<String>(value: t, child: Text(t)),
                    )
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
                    .map(
                      (t) => DropdownMenuItem<String>(value: t, child: Text(t)),
                    )
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
                      .map(
                        (t) =>
                            DropdownMenuItem<String>(value: t, child: Text(t)),
                      )
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
              .map(
                (r) => DropdownMenuItem<String>(
                  value: r,
                  child: Text(r, overflow: TextOverflow.ellipsis),
                ),
              )
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

  Widget _buildOptionSelectionSection(
    AsyncValue<List<QuotationOptionModel>> optionsAsync,
  ) {
    return optionsAsync.when(
      data: (options) {
        final groups = <String, String>{
          'FLOOR': 'Sàn',
          'DOOR': 'Cửa',
          'WALL': 'Vách / hông / nóc',
          'AC': 'Máy lạnh',
          'LIGHT': 'Đèn',
          'ACCESSORY': 'Phụ kiện',
          'OTHER': 'Khác',
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PriceSummary(
              basePrice: _templateBasePrice,
              optionTotal: _optionTotal,
              estimatedTotal: _estimatedTotal,
            ),
            const SizedBox(height: 12),
            for (final entry in groups.entries)
              _OptionGroup(
                title: entry.value,
                selected: _selectedQuotationOptions
                    .where((option) => option.position == entry.key)
                    .toList(),
                onAdd: () => _showOptionPicker(entry.key, entry.value, options),
                onRemove: (item) =>
                    setState(() => _selectedQuotationOptions.remove(item)),
              ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (e, _) => Text(
        'Không tải được kho option: $e',
        style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
      ),
    );
  }

  Future<void> _showOptionPicker(
    String position,
    String title,
    List<QuotationOptionModel> options,
  ) async {
    final filtered = options
        .where((option) => option.position.toUpperCase() == position)
        .toList();
    final customNameCtrl = TextEditingController();
    final customQtyCtrl = TextEditingController(text: '1');
    final customPriceCtrl = TextEditingController();
    final customNoteCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thêm option $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                const Text(
                  'Chưa có option trong nhóm này. Có thể nhập yêu cầu ngoài danh mục bên dưới.',
                  style: TextStyle(color: AppColors.textGray, fontSize: 12),
                )
              else
                ...filtered.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.name),
                    subtitle: Text(
                      '${_formatMoney(option.defaultPrice)} / ${option.unit}',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      setState(() {
                        _selectedQuotationOptions.add(
                          _SelectedQuotationOption.fromCatalog(option),
                        );
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              const Divider(height: 24),
              const Text(
                'Yêu cầu ngoài danh mục',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên yêu cầu / option',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customQtyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: customPriceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Giá tạm tính',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customNoteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm yêu cầu ngoài danh mục'),
                  onPressed: () {
                    if (customNameCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _selectedQuotationOptions.add(
                        _SelectedQuotationOption.custom(
                          name: customNameCtrl.text.trim(),
                          position: position,
                          quantity: int.tryParse(customQtyCtrl.text) ?? 1,
                          unitPrice: double.tryParse(customPriceCtrl.text) ?? 0,
                          note: customNoteCtrl.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelFoamSection() {
    const surfaces = ['Sàn', 'Đầu', 'Hông', 'Nóc', 'Cửa'];
    final panelVals = [
      _panelFloor,
      _panelFront,
      _panelSide,
      _panelRoof,
      _panelDoor,
    ];
    final panelSetters = <void Function(String?)>[
      (v) => setState(() => _panelFloor = v),
      (v) => setState(() => _panelFront = v),
      (v) => setState(() => _panelSide = v),
      (v) => setState(() => _panelRoof = v),
      (v) => setState(() => _panelDoor = v),
    ];
    final foamCtrls = [
      _foamFloorCtrl,
      _foamFrontCtrl,
      _foamSideCtrl,
      _foamRoofCtrl,
      _foamDoorCtrl,
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
                  child: Text(
                    surfaces[i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: panelVals[i],
                    isDense: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      hintText: 'Panel',
                    ),
                    isExpanded: true,
                    items: _kPanelCodes
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
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
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
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
      Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    ],
  );

  Widget _dimRow(List<TextEditingController> ctrls, List<String> labels) {
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

  Widget _cbWithQty(
    String label,
    bool value,
    TextEditingController qtyCtrl,
    ValueChanged<bool?> onChanged,
  ) {
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
              decoration: const InputDecoration(labelText: 'SL', isDense: true),
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
            color: selected ? AppColors.primaryOrange : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textGray,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedQuotationOption {
  final String? optionId;
  final String name;
  final String position;
  final String unit;
  final double unitPrice;
  final int quantity;
  final String? note;
  final bool isCustom;

  const _SelectedQuotationOption({
    this.optionId,
    required this.name,
    required this.position,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    this.note,
    required this.isCustom,
  });

  factory _SelectedQuotationOption.fromCatalog(QuotationOptionModel option) {
    return _SelectedQuotationOption(
      optionId: option.id,
      name: option.name,
      position: option.position.toUpperCase(),
      unit: option.unit,
      unitPrice: option.defaultPrice,
      quantity: 1,
      isCustom: false,
    );
  }

  factory _SelectedQuotationOption.custom({
    required String name,
    required String position,
    required int quantity,
    required double unitPrice,
    String? note,
  }) {
    return _SelectedQuotationOption(
      name: name,
      position: position.toUpperCase(),
      unit: 'cái',
      unitPrice: unitPrice,
      quantity: quantity > 0 ? quantity : 1,
      note: note == null || note.isEmpty ? null : note,
      isCustom: true,
    );
  }

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toPayload() => {
    if (optionId != null) 'optionId': int.tryParse(optionId!),
    'name': name,
    'position': position,
    'unit': unit,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'note': ?note,
    'isCustom': isCustom,
  };
}

class _PriceSummary extends StatelessWidget {
  final double basePrice;
  final double optionTotal;
  final double estimatedTotal;

  const _PriceSummary({
    required this.basePrice,
    required this.optionTotal,
    required this.estimatedTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          _MoneyRow(label: 'Giá nền mẫu', value: basePrice),
          _MoneyRow(label: 'Tổng option', value: optionTotal),
          const Divider(height: 14),
          _MoneyRow(
            label: 'Tạm tính nội bộ',
            value: estimatedTotal,
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
              color: AppColors.textGray,
            ),
          ),
        ),
        Text(
          _formatMoney(value),
          style: TextStyle(
            fontSize: strong ? 15 : 13,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            color: strong ? AppColors.primaryOrange : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _OptionGroup extends StatelessWidget {
  final String title;
  final List<_SelectedQuotationOption> selected;
  final VoidCallback onAdd;
  final ValueChanged<_SelectedQuotationOption> onRemove;

  const _OptionGroup({
    required this.title,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm'),
              ),
            ],
          ),
          if (selected.isEmpty)
            const Text(
              'Chưa chọn option',
              style: TextStyle(color: AppColors.textGray, fontSize: 12),
            )
          else
            ...selected.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity} ${item.unit} x ${_formatMoney(item.unitPrice)}'
                  '${item.isCustom ? ' • ngoài danh mục' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMoney(item.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => onRemove(item),
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

String _formatMoney(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$bufferđ';
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
                const Text(
                  'Chọn Khách Hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
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
                        final name = (c['fullName'] as String? ?? '')
                            .toLowerCase();
                        final phone = (c['phone'] as String? ?? '')
                            .toLowerCase();
                        return name.contains(_query) || phone.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Không tìm thấy khách hàng'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryOrange.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          (c['fullName'] as String? ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        c['fullName'] as String? ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        c['phone'] as String? ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => Navigator.pop(context, {
                        'id': c['id'] as int,
                        'name': c['fullName'] as String? ?? '?',
                      }),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorRed),
                    const SizedBox(height: 8),
                    Text(
                      '$e',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(_customerListProvider),
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
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
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
