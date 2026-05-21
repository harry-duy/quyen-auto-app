import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/request/quotation_request.dart';
import '../../domain/entities/product.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kBoxCategories = ['THÙNG ĐÔNG LẠNH-BẢO ÔN', 'THÙNG TẢI KÍN'];

const _kVehicleModels = [
  // ── ISUZU ────────────────────────────────────────────────
  'ISUZU QMR77HE5 (2.5T)',
  'ISUZU QKR270 (1.9T)',
  'ISUZU NPR85HE (3.5T)',
  'ISUZU NQR75LE (5T)',
  'ISUZU FRR90 (6.2T)',
  'ISUZU FSR-N 2026 (7T)',
  'ISUZU FVM1500 (15T)',
  // ── HINO ─────────────────────────────────────────────────
  'HINO 300 XZU342 (3.5T)',
  'HINO 300 XZU720 (5T)',
  'HINO 500 FC9JLSW (6.4T)',
  'HINO 500 FG8JPSW (10T)',
  'HINO 500 FG (14T)',
  // ── HYUNDAI ──────────────────────────────────────────────
  'HYUNDAI HD35 (1.5T)',
  'HYUNDAI HD65 (2.5T)',
  'HYUNDAI HD72 (3.5T)',
  'HYUNDAI HD99 (7T)',
  'HYUNDAI HD120 (8T)',
  // ── MITSUBISHI FUSO ──────────────────────────────────────
  'MITSUBISHI FUSO Canter (3.5T)',
  'MITSUBISHI FUSO Fighter (7T)',
  // ── Loại khác ────────────────────────────────────────────
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
const _kRearPillarTypes = ['SBL', 'BLT', 'BLD', 'CND'];
const _kPanelCodes = [
  'E1-F', 'E1-C', 'E2', 'A1', 'A2', 'E3',
  'RPB', 'CPB', 'RLL', 'CLL', 'S-CS', 'T-CS',
];
const _kEquipmentOptions = [
  'Máy Oxy: RT90-M + ZLE-50LA',
  'Bửng nâng hạ DLC3',
  'Đèn LED trong thùng',
  'Cửa cuốn phía sau',
  'Kệ thép inox trong thùng',
];

// ─── Main screen ──────────────────────────────────────────────────────────────

class QuotationFormScreen extends ConsumerStatefulWidget {
  final String? preselectedProductId;
  const QuotationFormScreen({super.key, this.preselectedProductId});

  @override
  ConsumerState<QuotationFormScreen> createState() =>
      _QuotationFormScreenState();
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // ─── Step 1: Thông tin cơ bản ────────────────────────────────────────────
  String _boxCategory = _kBoxCategories[0];
  String? _selectedProductId;
  String? _vehicleModel;
  final _quantityCtrl = TextEditingController(text: '1');
  final _chassisWidthCtrl = TextEditingController();
  final _boxCodeCtrl = TextEditingController();
  String? _boxType;
  String? _pillarType;         // Loại trụ (NH/INOX)
  String? _doorGasketType;    // Loại roon cửa
  String? _floorType;          // Loại sàn
  String? _acType;             // Loại máy lạnh
  final _acModelCtrl = TextEditingController();
  bool _innerWallInsulated = false; // Mặt trong Panel TK

  // Kích thước phủ bì (mm)
  final _outerLengthCtrl = TextEditingController();
  final _outerWidthCtrl = TextEditingController();
  final _outerHeightCtrl = TextEditingController();

  // Kích thước lọt lòng (mm)
  final _innerLengthCtrl = TextEditingController();
  final _innerWidthCtrl = TextEditingController();
  final _innerHeightCtrl = TextEditingController();

  // ─── Step 2: Phụ kiện & trang bị ────────────────────────────────────────
  String? _floorRequirement;  // Yêu cầu sàn

  bool _sideLight = false;
  final _sideLightQtyCtrl = TextEditingController(text: '0');
  bool _cabinRack = false;
  final _cabinRackQtyCtrl = TextEditingController(text: '1');
  bool _ladder = false;
  final _ladderQtyCtrl = TextEditingController(text: '1');

  bool _sideDoorPassenger = false;
  bool _sideDoorDriver = false;
  bool _rearDoorPassenger = false;
  bool _rearDoorDriver = false;

  bool _innerWallCargo = false; // Vách trong tải kín
  bool _oxyPipeFront = false;
  bool _oxyPipeSide = false;

  bool _oxyMachine = false;           // Máy Oxy RT90-M + ZLE-50LA
  final _oxyMachineQtyCtrl = TextEditingController(text: '1');
  bool _liftingGateDLC3 = false;      // Bửng nâng hạ DLC3
  final _liftingGateDLC3QtyCtrl = TextEditingController(text: '1');

  final _equip1Ctrl = TextEditingController();
  final _equip2Ctrl = TextEditingController();
  final _equip3Ctrl = TextEditingController();

  // ─── Step 3: Thông số kỹ thuật ──────────────────────────────────────────
  // Panel type per surface
  String? _panelFloor;
  String? _panelFront;
  String? _panelSide;
  String? _panelRoof;
  String? _panelDoor;

  // Foam thickness per surface (mm)
  final _foamFloorCtrl = TextEditingController(text: '60');
  final _foamFrontCtrl = TextEditingController(text: '60');
  final _foamSideCtrl = TextEditingController(text: '60');
  final _foamRoofCtrl = TextEditingController(text: '75');
  final _foamDoorCtrl = TextEditingController(text: '60');

  // Khung trụ sau
  String? _rearPillarFrame;

  // Thông số phủ bì lam trụ
  final _pillarCNTCtrl = TextEditingController();   // CN-T
  final _pillarCDCtrl = TextEditingController();    // CD
  final _pillarCNDCtrl = TextEditingController();   // CN-D

  // Đà sàn
  final _floorBeamCtrl = TextEditingController();

  // ─── Step 4: Option khác ────────────────────────────────────────────────
  bool _airTubeStandard = false;
  final _airTubeStdQtyCtrl = TextEditingController(text: '0');
  bool _airTubeHorizontal = false;
  final _airTubeHrzQtyCtrl = TextEditingController(text: '0');
  bool _protectionPart = false;
  final _protectionPartQtyCtrl = TextEditingController(text: '0');
  bool _airChamberCap = false;
  final _airChamberCapQtyCtrl = TextEditingController(text: '0');
  bool _tankCap = false;
  final _tankCapQtyCtrl = TextEditingController(text: '0');
  bool _traceCargo = false;
  final _traceCargoQtyCtrl = TextEditingController(text: '0');

  final _noteCtrl = TextEditingController();

  // Guest contact info (shown in Step 4 when not logged in)
  final _guestPhoneCtrl = TextEditingController();
  final _guestNameCtrl = TextEditingController();
  bool _guestSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.preselectedProductId;
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> get _allControllers => [
        _quantityCtrl, _chassisWidthCtrl, _boxCodeCtrl,
        _acModelCtrl,
        _outerLengthCtrl, _outerWidthCtrl, _outerHeightCtrl,
        _innerLengthCtrl, _innerWidthCtrl, _innerHeightCtrl,
        _sideLightQtyCtrl, _cabinRackQtyCtrl, _ladderQtyCtrl,
        _oxyMachineQtyCtrl, _liftingGateDLC3QtyCtrl,
        _equip1Ctrl, _equip2Ctrl, _equip3Ctrl,
        _foamFloorCtrl, _foamFrontCtrl, _foamSideCtrl, _foamRoofCtrl, _foamDoorCtrl,
        _pillarCNTCtrl, _pillarCDCtrl, _pillarCNDCtrl,
        _floorBeamCtrl,
        _airTubeStdQtyCtrl, _airTubeHrzQtyCtrl, _protectionPartQtyCtrl,
        _airChamberCapQtyCtrl, _tankCapQtyCtrl, _traceCargoQtyCtrl,
        _noteCtrl,
        _guestPhoneCtrl, _guestNameCtrl,
      ];

  // ─── Build spec JSON ─────────────────────────────────────────────────────
  Map<String, dynamic> _buildSpecifications() {
    return {
      'boxCategory': _boxCategory,
      'dimensions': {
        'outer': {
          'length': int.tryParse(_outerLengthCtrl.text),
          'width': int.tryParse(_outerWidthCtrl.text),
          'height': int.tryParse(_outerHeightCtrl.text),
        },
        'inner': {
          'length': int.tryParse(_innerLengthCtrl.text),
          'width': int.tryParse(_innerWidthCtrl.text),
          'height': int.tryParse(_innerHeightCtrl.text),
        },
      },
      'pillarType': _pillarType,
      'doorGasketType': _doorGasketType,
      'floor': {
        'type': _floorType,
        'requirement': _floorRequirement,
      },
      'innerWallCargo': _innerWallCargo,
      'doors': {
        'sideDoorPassenger': _sideDoorPassenger,
        'sideDoorDriver': _sideDoorDriver,
        'rearDoorPassenger': _rearDoorPassenger,
        'rearDoorDriver': _rearDoorDriver,
      },
      'sideLight': {
        'enabled': _sideLight,
        'qty': _sideLight ? (int.tryParse(_sideLightQtyCtrl.text) ?? 0) : 0,
      },
      'cabinRack': {
        'enabled': _cabinRack,
        'qty': _cabinRack ? (int.tryParse(_cabinRackQtyCtrl.text) ?? 1) : 0,
      },
      'ladder': {
        'enabled': _ladder,
        'qty': _ladder ? (int.tryParse(_ladderQtyCtrl.text) ?? 1) : 0,
      },
      'oxyPipeFront': _oxyPipeFront,
      'oxyPipeSide': _oxyPipeSide,
      'oxyMachine': {
        'enabled': _oxyMachine,
        'qty': _oxyMachine ? (int.tryParse(_oxyMachineQtyCtrl.text) ?? 1) : 0,
      },
      'liftingGateDLC3': {
        'enabled': _liftingGateDLC3,
        'qty': _liftingGateDLC3 ? (int.tryParse(_liftingGateDLC3QtyCtrl.text) ?? 1) : 0,
      },
      'equipments': [
        if (_equip1Ctrl.text.trim().isNotEmpty) _equip1Ctrl.text.trim(),
        if (_equip2Ctrl.text.trim().isNotEmpty) _equip2Ctrl.text.trim(),
        if (_equip3Ctrl.text.trim().isNotEmpty) _equip3Ctrl.text.trim(),
      ],
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
      'rearPillarFrame': _rearPillarFrame,
      'pillarTrim': {
        'CNT': int.tryParse(_pillarCNTCtrl.text),
        'CD': int.tryParse(_pillarCDCtrl.text),
        'CND': int.tryParse(_pillarCNDCtrl.text),
      },
      'floorBeam': _floorBeamCtrl.text.trim().isEmpty ? null : _floorBeamCtrl.text.trim(),
      'options': {
        'airTubeStandard': {'enabled': _airTubeStandard, 'qty': int.tryParse(_airTubeStdQtyCtrl.text) ?? 0},
        'airTubeHorizontal': {'enabled': _airTubeHorizontal, 'qty': int.tryParse(_airTubeHrzQtyCtrl.text) ?? 0},
        'protectionPart': {'enabled': _protectionPart, 'qty': int.tryParse(_protectionPartQtyCtrl.text) ?? 0},
        'airChamberCap': {'enabled': _airChamberCap, 'qty': int.tryParse(_airChamberCapQtyCtrl.text) ?? 0},
        'tankCap': {'enabled': _tankCap, 'qty': int.tryParse(_tankCapQtyCtrl.text) ?? 0},
        'traceCargo': {'enabled': _traceCargo, 'qty': int.tryParse(_traceCargoQtyCtrl.text) ?? 0},
      },
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    FocusScope.of(context).unfocus();

    final isLoggedIn = ref.read(isAuthenticatedProvider);
    if (isLoggedIn) {
      await _submitAsUser();
    } else {
      await _submitAsGuest();
    }
  }

  Future<void> _submitAsUser() async {
    final request = QuotationRequest(
      productId: int.parse(_selectedProductId!),
      vehicleModel: _vehicleModel ?? '',
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      chassisWidth: int.tryParse(_chassisWidthCtrl.text),
      boxCode: _boxCodeCtrl.text.trim().isEmpty ? null : _boxCodeCtrl.text.trim(),
      boxType: _boxType,
      acType: _acType,
      acModel: _acModelCtrl.text.trim().isEmpty ? null : _acModelCtrl.text.trim(),
      innerWallInsulated: _innerWallInsulated,
      specifications: _buildSpecifications(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    final success = await ref.read(quotationProvider.notifier).submit(request);
    if (!mounted) return;

    if (success) {
      _showSuccessDialog(ref.read(quotationProvider).value?.orderCode ?? '');
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

  Future<void> _submitAsGuest() async {
    setState(() => _guestSubmitting = true);
    try {
      final api = ref.read(apiServiceProvider);
      final allProducts = ref.read(productListProvider).valueOrNull ?? [];
      final matchedProducts = allProducts.where((p) => p.id == _selectedProductId);
      final productName = matchedProducts.isEmpty ? null : matchedProducts.first.name;

      await api.post(ApiConstants.guestLead, data: {
        'phone': _guestPhoneCtrl.text.trim(),
        if (_guestNameCtrl.text.trim().isNotEmpty)
          'name': _guestNameCtrl.text.trim(),
        if (_selectedProductId != null)
          'productId': int.tryParse(_selectedProductId!),
        'productName': ?productName,
        'specifications': jsonEncode(_buildSpecifications()),
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
      });
      if (!mounted) return;
      _showGuestSuccessDialog();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _guestSubmitting = false);
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.successGreen, size: 40),
            ),
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
              'Nhân viên Quyen Auto sẽ liên hệ với bạn trong thời gian sớm nhất.',
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
                context.go(AppRoutes.orders);
              },
              child: const Text('Xem đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isAuthenticatedProvider);
    final isLoading = ref.watch(quotationProvider).isLoading || _guestSubmitting;
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Tạo yêu cầu báo giá')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            // Step 4: submit button is embedded in content; show only "Quay lại" here
            if (_currentStep == 3) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Quay lại'),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : details.onStepContinue,
                      child: const Text('Tiếp theo'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Quay lại'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Thông tin cơ bản'),
              subtitle: const Text('Loại xe, kích thước thùng'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStep1(productsAsync),
            ),
            Step(
              title: const Text('Phụ kiện & trang bị'),
              subtitle: const Text('Sàn, cửa, thang leo, thiết bị'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildStep2(),
            ),
            Step(
              title: const Text('Thông số kỹ thuật'),
              subtitle: const Text('Panel, foam, khung trụ'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildStep3(),
            ),
            Step(
              title: const Text('Tùy chọn & ghi chú'),
              subtitle: const Text('Option khác, ghi chú thêm'),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
              content: _buildStep4(isLoggedIn, isLoading),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1 ───────────────────────────────────────────────────────────────

  Widget _buildStep1(AsyncValue<List<Product>> productsAsync) {
    final isRefrigerated = _boxCategory == _kBoxCategories[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại thùng (big category selector)
        _label('Loại thùng *'),
        const SizedBox(height: 8),
        Row(
          children: _kBoxCategories.map((cat) {
            final selected = _boxCategory == cat;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _boxCategory = cat),
                child: Container(
                  margin: EdgeInsets.only(
                      right: cat == _kBoxCategories[0] ? 6 : 0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryOrange
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
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
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Sản phẩm
        _label('Sản phẩm *'),
        const SizedBox(height: 8),
        productsAsync.when(
          data: (products) {
            final filtered = products.where((p) => p.id == _selectedProductId);
            final selected = filtered.isEmpty ? null : filtered.first;
            if (selected != null) {
              return _selectedProductCard(selected.name, selected.truckType);
            }
            return DropdownButtonFormField<String>(
              initialValue: _selectedProductId,
              decoration: const InputDecoration(
                labelText: 'Chọn sản phẩm *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              isExpanded: true,
              items: products
                  .map((p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProductId = v),
              validator: (v) => v == null ? 'Vui lòng chọn sản phẩm' : null,
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => OutlinedButton.icon(
            onPressed: () => ref.invalidate(productListProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại danh sách'),
          ),
        ),

        const SizedBox(height: 16),

        // Kiểu loại xe
        _label('Kiểu loại xe *'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _vehicleModel,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.directions_car_outlined),
            labelText: 'Chọn kiểu loại xe *',
          ),
          isExpanded: true,
          items: _kVehicleModels
              .map((m) => DropdownMenuItem<String>(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _vehicleModel = v),
          validator: (v) => v == null ? 'Vui lòng chọn kiểu loại xe' : null,
        ),

        const SizedBox(height: 16),

        // Số lượng & Rộng chassis
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Số lượng'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Rộng chassis xe (mm)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _chassisWidthCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Rộng chassis'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Mã thùng & Loại
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Mã thùng'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _boxCodeCtrl,
                    decoration: const InputDecoration(hintText: 'VD: 001/26'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Loại'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _boxType,
                    decoration: const InputDecoration(labelText: 'Loại'),
                    isExpanded: true,
                    items: _kBoxTypes
                        .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _boxType = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Loại sàn & Loại trụ
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Loại sàn'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _floorType,
                    decoration: const InputDecoration(labelText: 'Loại sàn'),
                    isExpanded: true,
                    items: _kFloorTypes
                        .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _floorType = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Loại trụ'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _pillarType,
                    decoration: const InputDecoration(labelText: 'Loại trụ'),
                    isExpanded: true,
                    items: _kPillarTypes
                        .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _pillarType = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Loại roon cửa
        _label('Loại roon cửa'),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _doorGasketType,
          decoration: const InputDecoration(
            hintText: 'VD: LL cửa hông',
            prefixIcon: Icon(Icons.door_sliding_outlined),
          ),
          onChanged: (v) => _doorGasketType = v.trim().isEmpty ? null : v.trim(),
        ),

        const SizedBox(height: 16),

        // Kích thước phủ bì
        _label('Kích thước phủ bì (mm)'),
        const SizedBox(height: 8),
        _dimensionRow(
          controllers: [_outerLengthCtrl, _outerWidthCtrl, _outerHeightCtrl],
          labels: ['Dài', 'Rộng', 'Cao'],
        ),

        const SizedBox(height: 16),

        // Kích thước lọt lòng
        _label('Kích thước lọt lòng (mm)'),
        const SizedBox(height: 8),
        _dimensionRow(
          controllers: [_innerLengthCtrl, _innerWidthCtrl, _innerHeightCtrl],
          labels: ['Dài', 'Rộng', 'Cao'],
        ),

        if (isRefrigerated) ...[
          const SizedBox(height: 16),

          // Máy lạnh (chỉ hiện khi ĐÔNG LẠNH)
          _label('Máy lạnh'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _acType,
                  decoration: const InputDecoration(labelText: 'Loại máy lạnh'),
                  isExpanded: true,
                  items: _kAcTypes
                      .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _acType = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _acModelCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Model', hintText: 'VD: T-2500 12V'),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),

        // Mặt trong Panel TK
        _checkboxTile(
          label: 'Mặt trong Panel TK',
          value: _innerWallInsulated,
          onChanged: (v) => setState(() => _innerWallInsulated = v ?? false),
        ),
      ],
    );
  }

  // ─── Step 2 ───────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yêu cầu sàn
        _label('Yêu cầu sàn'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _floorRequirement,
          decoration: const InputDecoration(labelText: 'Yêu cầu sàn'),
          isExpanded: true,
          items: _kFloorRequirements
              .map((r) => DropdownMenuItem<String>(
                    value: r,
                    child: Text(r, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _floorRequirement = v),
        ),

        const SizedBox(height: 16),

        // Đèn hông / Baga cabin / Thang leo
        _label('Phụ kiện ngoài'),
        _checkboxWithQty(
          label: 'Đèn hông',
          value: _sideLight,
          qtyCtrl: _sideLightQtyCtrl,
          onChanged: (v) => setState(() => _sideLight = v ?? false),
        ),
        _checkboxWithQty(
          label: 'Baga cabin',
          value: _cabinRack,
          qtyCtrl: _cabinRackQtyCtrl,
          onChanged: (v) => setState(() => _cabinRack = v ?? false),
        ),
        _checkboxWithQty(
          label: 'Thang leo',
          value: _ladder,
          qtyCtrl: _ladderQtyCtrl,
          onChanged: (v) => setState(() => _ladder = v ?? false),
        ),

        const SizedBox(height: 16),

        // Cửa
        _label('Cửa'),
        _checkboxTile(
          label: 'Cửa hông phụ',
          value: _sideDoorPassenger,
          onChanged: (v) => setState(() => _sideDoorPassenger = v ?? false),
        ),
        _checkboxTile(
          label: 'Cửa hông tài',
          value: _sideDoorDriver,
          onChanged: (v) => setState(() => _sideDoorDriver = v ?? false),
        ),
        _checkboxTile(
          label: 'Cửa sau phụ',
          value: _rearDoorPassenger,
          onChanged: (v) => setState(() => _rearDoorPassenger = v ?? false),
        ),
        _checkboxTile(
          label: 'Cửa sau tài',
          value: _rearDoorDriver,
          onChanged: (v) => setState(() => _rearDoorDriver = v ?? false),
        ),

        const SizedBox(height: 16),

        // Vách / Ống OXY
        _label('Vách & hệ thống lạnh'),
        _checkboxTile(
          label: 'Vách trong tải kín',
          value: _innerWallCargo,
          onChanged: (v) => setState(() => _innerWallCargo = v ?? false),
        ),
        _checkboxTile(
          label: 'Ống OXY đầu',
          value: _oxyPipeFront,
          onChanged: (v) => setState(() => _oxyPipeFront = v ?? false),
        ),
        _checkboxTile(
          label: 'Ống OXY hông',
          value: _oxyPipeSide,
          onChanged: (v) => setState(() => _oxyPipeSide = v ?? false),
        ),
        _checkboxWithQty(
          label: 'Máy Oxy: RT90-M + ZLE-50LA',
          value: _oxyMachine,
          qtyCtrl: _oxyMachineQtyCtrl,
          onChanged: (v) => setState(() => _oxyMachine = v ?? false),
        ),
        _checkboxWithQty(
          label: 'Bửng nâng hạ DLC3',
          value: _liftingGateDLC3,
          qtyCtrl: _liftingGateDLC3QtyCtrl,
          onChanged: (v) => setState(() => _liftingGateDLC3 = v ?? false),
        ),

        const SizedBox(height: 16),

        // Thiết bị
        _label('Thiết bị khác'),
        const SizedBox(height: 8),
        _equipmentField(_equip1Ctrl, 'Thiết bị # 1'),
        const SizedBox(height: 8),
        _equipmentField(_equip2Ctrl, 'Thiết bị # 2'),
        const SizedBox(height: 8),
        _equipmentField(_equip3Ctrl, 'Thiết bị # 3'),
      ],
    );
  }

  // ─── Step 3 ───────────────────────────────────────────────────────────────

  Widget _buildStep3() {
    const surfaces = ['Sàn', 'Đầu', 'Hông', 'Nóc', 'Cửa'];

    final panelValues = [_panelFloor, _panelFront, _panelSide, _panelRoof, _panelDoor];
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel & Foam table
        _label('Thông số Panel & Foam (mm)'),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(
              color: AppColors.borderLight.withValues(alpha: 0.5), width: 0.8),
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1)),
              children: const [
                _TableCell(text: 'Bề mặt', header: true),
                _TableCell(text: 'Loại Panel', header: true),
                _TableCell(text: 'Foam', header: true),
              ],
            ),
            // Data rows
            for (int i = 0; i < surfaces.length; i++)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Text(surfaces[i],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: DropdownButtonFormField<String>(
                      initialValue: panelValues[i],
                      isDense: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        hintText: 'Chọn',
                      ),
                      isExpanded: true,
                      items: _kPanelCodes
                          .map((c) =>
                              DropdownMenuItem<String>(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: panelSetters[i],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: TextFormField(
                      controller: foamCtrls[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        suffixText: 'mm',
                        suffixStyle: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Khung trụ sau
        _label('Khung trụ sau'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _rearPillarFrame,
          decoration: const InputDecoration(labelText: 'Khung trụ sau'),
          isExpanded: true,
          items: _kRearPillarTypes
              .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _rearPillarFrame = v),
        ),

        const SizedBox(height: 16),

        // Thông số phủ bì lam trụ (CN-T, CD, CN-D)
        _label('Thông số phủ bì lam trụ (mm)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pillarCNTCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'CN-T', isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _pillarCDCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'CD', isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _pillarCNDCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'CN-D', isDense: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Đà sàn
        _label('Đà sàn'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _floorBeamCtrl,
          decoration: const InputDecoration(
            hintText: 'Thông số đà sàn...',
            prefixIcon: Icon(Icons.table_rows_outlined),
          ),
        ),
      ],
    );
  }

  // ─── Step 4 ───────────────────────────────────────────────────────────────

  Widget _buildStep4(bool isLoggedIn, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thông tin liên hệ — chỉ hiện khi chưa đăng nhập
        if (!isLoggedIn) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk_outlined,
                    color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Để lại số điện thoại để nhân viên liên hệ gửi báo giá',
                    style: TextStyle(fontSize: 13, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _guestPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại *',
              hintText: '0901234567',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              if (!isLoggedIn) {
                if (v == null || v.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^0[3-9]\d{8}$').hasMatch(v.trim())) {
                  return 'Số điện thoại không hợp lệ';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _guestNameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ tên (tuỳ chọn)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
        ],

        _label('Option khác'),
        const SizedBox(height: 8),

        _checkboxWithQty(
          label: 'Lòn hơi tiêu chuẩn',
          value: _airTubeStandard,
          qtyCtrl: _airTubeStdQtyCtrl,
          onChanged: (v) => setState(() => _airTubeStandard = v ?? false),
        ),
        const SizedBox(height: 4),
        _checkboxWithQty(
          label: 'Lòn hơi lắp ngang',
          value: _airTubeHorizontal,
          qtyCtrl: _airTubeHrzQtyCtrl,
          onChanged: (v) => setState(() => _airTubeHorizontal = v ?? false),
        ),
        const SizedBox(height: 4),
        _checkboxWithQty(
          label: 'Part bảo vệ',
          value: _protectionPart,
          qtyCtrl: _protectionPartQtyCtrl,
          onChanged: (v) => setState(() => _protectionPart = v ?? false),
        ),
        const SizedBox(height: 4),
        _checkboxWithQty(
          label: 'Nắp bầu hơi',
          value: _airChamberCap,
          qtyCtrl: _airChamberCapQtyCtrl,
          onChanged: (v) => setState(() => _airChamberCap = v ?? false),
        ),
        const SizedBox(height: 4),
        _checkboxWithQty(
          label: 'Nắp bình',
          value: _tankCap,
          qtyCtrl: _tankCapQtyCtrl,
          onChanged: (v) => setState(() => _tankCap = v ?? false),
        ),
        const SizedBox(height: 4),
        _checkboxWithQty(
          label: 'Thùng vết',
          value: _traceCargo,
          qtyCtrl: _traceCargoQtyCtrl,
          onChanged: (v) => setState(() => _traceCargo = v ?? false),
        ),

        const SizedBox(height: 24),

        _label('Ghi chú thêm'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Yêu cầu đặc biệt, thông tin thêm...',
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              isLoggedIn ? 'Gửi báo giá' : 'Gửi yêu cầu',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _label(String text) {
    return Row(
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
  }

  Widget _selectedProductCard(String name, String? type) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: AppColors.primaryOrange, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textDark)),
                if (type != null)
                  Text(type,
                      style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _selectedProductId = null),
          ),
        ],
      ),
    );
  }

  Widget _dimensionRow({
    required List<TextEditingController> controllers,
    required List<String> labels,
  }) {
    return Row(
      children: List.generate(controllers.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < controllers.length - 1 ? 8 : 0),
            child: TextFormField(
              controller: controllers[i],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: labels[i]),
            ),
          ),
        );
      }),
    );
  }

  Widget _checkboxTile({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.primaryOrange,
    );
  }

  Widget _checkboxWithQty({
    required String label,
    required bool value,
    required TextEditingController qtyCtrl,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: _checkboxTile(label: label, value: value, onChanged: onChanged),
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

  Widget _equipmentField(TextEditingController ctrl, String hint) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const [];
        return _kEquipmentOptions.where((o) =>
            o.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (v) => ctrl.text = v,
      fieldViewBuilder: (_, fieldCtrl, focusNode, _) {
        fieldCtrl.text = ctrl.text;
        fieldCtrl.addListener(() => ctrl.text = fieldCtrl.text);
        return TextFormField(
          controller: fieldCtrl,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.build_outlined, size: 18),
            isDense: true,
          ),
        );
      },
    );
  }
}

// ─── Table cell helper ────────────────────────────────────────────────────────

class _TableCell extends StatelessWidget {
  final String text;
  final bool header;
  const _TableCell({required this.text, this.header = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: header ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

