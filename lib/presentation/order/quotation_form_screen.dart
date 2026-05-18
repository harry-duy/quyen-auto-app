import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/request/quotation_request.dart';

// ─── Dữ liệu mẫu ──────────────────────────────────────────────────────────────

const _kBoxTypes = ['F2LB', 'F2LA', 'F2LC', 'L', 'S'];
const _kFloorTypes = ['C', 'L', 'U', 'M'];
const _kAcTypes = ['TN', 'KL', 'TL'];
const _kPillarMaterials = ['INOX', 'Nhôm'];
const _kFloorRequirements = [
  'Nhôm chống trượt',
  'Gỗ chống trượt',
  'Inox chống trượt',
  'Thép mạ kẽm',
];
const _kEquipmentOptions = [
  'Máy Oxy: RT90-M + ZLE-50LA',
  'Bửng nâng hạ DLC3',
  'Đèn LED trong thùng',
  'Cửa cuốn phía sau',
  'Kệ thép inox trong thùng',
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
  int _currentStep = 0;

  // ─── Thông tin cơ bản ────────────────────────────────────────────────────
  String? _selectedProductId;
  final _vehicleModelCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _chassisWidthCtrl = TextEditingController();
  final _boxCodeCtrl = TextEditingController();
  String? _boxType;
  String? _acType;
  final _acModelCtrl = TextEditingController();
  bool _innerWallInsulated = false;

  // Kích thước thùng phủ bì (mm)
  final _outerLengthCtrl = TextEditingController();
  final _outerWidthCtrl = TextEditingController();
  final _outerHeightCtrl = TextEditingController();

  // Kích thước thùng lọt lòng (mm)
  final _innerLengthCtrl = TextEditingController();
  final _innerWidthCtrl = TextEditingController();
  final _innerHeightCtrl = TextEditingController();

  // ─── Phụ kiện & trang bị ────────────────────────────────────────────────
  String? _floorType;
  String? _floorRequirement;
  String? _pillarMaterial;

  bool _sideDoorPassenger = false;
  final _sideDoorPassengerWCtrl = TextEditingController();
  final _sideDoorPassengerHCtrl = TextEditingController();

  bool _sideDoorDriver = false;
  bool _sideLight = false;
  final _sideLightQtyCtrl = TextEditingController(text: '0');
  bool _cabinRack = false;
  final _cabinRackQtyCtrl = TextEditingController(text: '1');
  bool _ladder = false;
  final _ladderQtyCtrl = TextEditingController(text: '1');
  bool _oxyPipeFront = false;
  bool _oxyPipeSide = false;

  final _equip1Ctrl = TextEditingController();
  final _equip2Ctrl = TextEditingController();
  final _equip3Ctrl = TextEditingController();

  // ─── Thông số kỹ thuật thùng tiêu chuẩn ────────────────────────────────
  final _foamFloorCtrl = TextEditingController(text: '60');
  final _foamFrontCtrl = TextEditingController(text: '60');
  final _foamSideCtrl = TextEditingController(text: '60');
  final _foamRoofCtrl = TextEditingController(text: '75');
  final _foamDoorCtrl = TextEditingController(text: '60');

  // ─── Option khác ────────────────────────────────────────────────────────
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
        _vehicleModelCtrl,
        _quantityCtrl,
        _chassisWidthCtrl,
        _boxCodeCtrl,
        _acModelCtrl,
        _outerLengthCtrl,
        _outerWidthCtrl,
        _outerHeightCtrl,
        _innerLengthCtrl,
        _innerWidthCtrl,
        _innerHeightCtrl,
        _sideDoorPassengerWCtrl,
        _sideDoorPassengerHCtrl,
        _sideLightQtyCtrl,
        _cabinRackQtyCtrl,
        _ladderQtyCtrl,
        _equip1Ctrl,
        _equip2Ctrl,
        _equip3Ctrl,
        _foamFloorCtrl,
        _foamFrontCtrl,
        _foamSideCtrl,
        _foamRoofCtrl,
        _foamDoorCtrl,
        _airTubeStdQtyCtrl,
        _airTubeHrzQtyCtrl,
        _protectionPartQtyCtrl,
        _airChamberCapQtyCtrl,
        _tankCapQtyCtrl,
        _traceCargoQtyCtrl,
        _noteCtrl,
      ];

  // ─── Build specifications JSON ───────────────────────────────────────────
  Map<String, dynamic> _buildSpecifications() {
    return {
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
      'floor': {
        'type': _floorType,
        'requirement': _floorRequirement,
      },
      'pillarFrame': _pillarMaterial,
      'sideDoorPassenger': {
        'enabled': _sideDoorPassenger,
        'width': _sideDoorPassenger
            ? int.tryParse(_sideDoorPassengerWCtrl.text)
            : null,
        'height': _sideDoorPassenger
            ? int.tryParse(_sideDoorPassengerHCtrl.text)
            : null,
      },
      'sideDoorDriver': _sideDoorDriver,
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
      'equipments': [
        if (_equip1Ctrl.text.trim().isNotEmpty) _equip1Ctrl.text.trim(),
        if (_equip2Ctrl.text.trim().isNotEmpty) _equip2Ctrl.text.trim(),
        if (_equip3Ctrl.text.trim().isNotEmpty) _equip3Ctrl.text.trim(),
      ],
      'foam': {
        'floor': int.tryParse(_foamFloorCtrl.text) ?? 60,
        'front': int.tryParse(_foamFrontCtrl.text) ?? 60,
        'side': int.tryParse(_foamSideCtrl.text) ?? 60,
        'roof': int.tryParse(_foamRoofCtrl.text) ?? 75,
        'door': int.tryParse(_foamDoorCtrl.text) ?? 60,
      },
      'options': {
        'airTubeStandard': {
          'enabled': _airTubeStandard,
          'qty': int.tryParse(_airTubeStdQtyCtrl.text) ?? 0,
        },
        'airTubeHorizontal': {
          'enabled': _airTubeHorizontal,
          'qty': int.tryParse(_airTubeHrzQtyCtrl.text) ?? 0,
        },
        'protectionPart': {
          'enabled': _protectionPart,
          'qty': int.tryParse(_protectionPartQtyCtrl.text) ?? 0,
        },
        'airChamberCap': {
          'enabled': _airChamberCap,
          'qty': int.tryParse(_airChamberCapQtyCtrl.text) ?? 0,
        },
        'tankCap': {
          'enabled': _tankCap,
          'qty': int.tryParse(_tankCapQtyCtrl.text) ?? 0,
        },
        'traceCargo': {
          'enabled': _traceCargo,
          'qty': int.tryParse(_traceCargoQtyCtrl.text) ?? 0,
        },
      },
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Chuyển về step đầu tiên bị lỗi
      setState(() => _currentStep = 0);
      return;
    }
    FocusScope.of(context).unfocus();

    final request = QuotationRequest(
      productId: int.parse(_selectedProductId!),
      vehicleModel: _vehicleModelCtrl.text.trim(),
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
                context.go(AppRoutes.orders);
              },
              child: const Text('Xem đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(quotationProvider).isLoading;

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
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : details.onStepContinue,
                    child: isLoading && _currentStep == 3
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(_currentStep < 3 ? 'Tiếp theo' : 'Gửi báo giá'),
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
          ),
          steps: [
            Step(
              title: const Text('Thông tin cơ bản'),
              subtitle: const Text('Loại xe, kích thước thùng'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep1(),
            ),
            Step(
              title: const Text('Phụ kiện & trang bị'),
              subtitle: const Text('Sàn, cửa, thang leo, thiết bị'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep2(),
            ),
            Step(
              title: const Text('Thông số kỹ thuật'),
              subtitle: const Text('Foam, panel tiêu chuẩn'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep3(),
            ),
            Step(
              title: const Text('Tùy chọn & ghi chú'),
              subtitle: const Text('Option khác, ghi chú thêm'),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
              content: _buildStep4(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Thông tin cơ bản ────────────────────────────────────────────

  Widget _buildStep1() {
    final productsAsync = ref.watch(productListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chọn sản phẩm
        _label('Sản phẩm *'),
        const SizedBox(height: 8),
        productsAsync.when(
          data: (products) {
            final selected =
                products.where((p) => p.id == _selectedProductId).firstOrNull;
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
                  .map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedProductId = v),
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

        const SizedBox(height: 16),

        // Kiểu loại xe
        _label('Kiểu loại xe *'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _vehicleModelCtrl,
          decoration: const InputDecoration(
            hintText: 'VD: ISUZU QMR77HE5',
            prefixIcon: Icon(Icons.directions_car_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Vui lòng nhập kiểu loại xe' : null,
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
                  _label('Rộng chassis (mm)'),
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

        // Kích thước thùng phủ bì
        _label('Kích thước thùng phủ bì (mm)'),
        const SizedBox(height: 8),
        _dimensionRow(
          controllers: [_outerLengthCtrl, _outerWidthCtrl, _outerHeightCtrl],
          labels: ['Dài', 'Rộng', 'Cao'],
        ),

        const SizedBox(height: 16),

        // Kích thước thùng lọt lòng
        _label('Kích thước thùng lọt lòng (mm)'),
        const SizedBox(height: 8),
        _dimensionRow(
          controllers: [_innerLengthCtrl, _innerWidthCtrl, _innerHeightCtrl],
          labels: ['Dài', 'Rộng', 'Cao'],
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
                    decoration:
                        const InputDecoration(hintText: 'VD: S2, S3...'),
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
                    value: _boxType,
                    decoration: const InputDecoration(labelText: 'Loại'),
                    isExpanded: true,
                    items: _kBoxTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _boxType = v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Máy lạnh
        _label('Máy lạnh'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _acType,
                decoration: const InputDecoration(labelText: 'Loại'),
                isExpanded: true,
                items: _kAcTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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

        const SizedBox(height: 12),

        // Vách trong tải kín
        _checkboxTile(
          label: 'Vách trong tải kín',
          value: _innerWallInsulated,
          onChanged: (v) => setState(() => _innerWallInsulated = v ?? false),
        ),
      ],
    );
  }

  // ─── Step 2: Phụ kiện & trang bị ────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loại sàn
        _label('Loại sàn'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _floorType,
                decoration: const InputDecoration(labelText: 'Loại sàn'),
                isExpanded: true,
                items: _kFloorTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _floorType = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _floorRequirement,
                decoration: const InputDecoration(labelText: 'Yêu cầu sàn'),
                isExpanded: true,
                items: _kFloorRequirements
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _floorRequirement = v),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Khung trụ
        _label('Khung trụ'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _pillarMaterial,
          decoration: const InputDecoration(labelText: 'Vật liệu khung trụ'),
          isExpanded: true,
          items: _kPillarMaterials
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => setState(() => _pillarMaterial = v),
        ),

        const SizedBox(height: 16),

        // Cửa hông phụ
        _checkboxTile(
          label: 'Cửa hông phụ',
          value: _sideDoorPassenger,
          onChanged: (v) => setState(() => _sideDoorPassenger = v ?? false),
        ),
        if (_sideDoorPassenger) ...[
          const SizedBox(height: 8),
          _dimensionRow(
            controllers: [_sideDoorPassengerWCtrl, _sideDoorPassengerHCtrl],
            labels: ['Rộng (mm)', 'Cao (mm)'],
          ),
        ],

        const SizedBox(height: 4),

        // Cửa hông tài
        _checkboxTile(
          label: 'Cửa hông tài',
          value: _sideDoorDriver,
          onChanged: (v) => setState(() => _sideDoorDriver = v ?? false),
        ),

        const SizedBox(height: 4),

        // Đèn hông
        _checkboxWithQty(
          label: 'Đèn hông',
          value: _sideLight,
          qtyCtrl: _sideLightQtyCtrl,
          onChanged: (v) => setState(() => _sideLight = v ?? false),
        ),

        const SizedBox(height: 4),

        // Baga cabin
        _checkboxWithQty(
          label: 'Baga cabin',
          value: _cabinRack,
          qtyCtrl: _cabinRackQtyCtrl,
          onChanged: (v) => setState(() => _cabinRack = v ?? false),
        ),

        const SizedBox(height: 4),

        // Thang leo
        _checkboxWithQty(
          label: 'Thang leo',
          value: _ladder,
          qtyCtrl: _ladderQtyCtrl,
          onChanged: (v) => setState(() => _ladder = v ?? false),
        ),

        const SizedBox(height: 12),

        // Ống OXY
        _label('Ống OXY'),
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

        const SizedBox(height: 16),

        // Thiết bị
        _label('Thiết bị'),
        const SizedBox(height: 8),
        _equipmentField(_equip1Ctrl, 'Thiết bị #1'),
        const SizedBox(height: 8),
        _equipmentField(_equip2Ctrl, 'Thiết bị #2'),
        const SizedBox(height: 8),
        _equipmentField(_equip3Ctrl, 'Thiết bị #3'),
      ],
    );
  }

  // ─── Step 3: Thông số kỹ thuật thùng tiêu chuẩn ─────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Foam (mm)'),
        const SizedBox(height: 12),
        _specTable(
          headers: const ['', 'Sàn', 'Đầu', 'Hông', 'Nóc', 'Cửa'],
          rowLabel: 'Foam',
          controllers: [
            _foamFloorCtrl,
            _foamFrontCtrl,
            _foamSideCtrl,
            _foamRoofCtrl,
            _foamDoorCtrl,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Giá trị mặc định theo tiêu chuẩn thùng đông lạnh. Có thể điều chỉnh theo yêu cầu.',
          style: TextStyle(
              fontSize: 12, color: AppColors.textGray.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  // ─── Step 4: Option khác & Ghi chú ──────────────────────────────────────

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  // ─── Widgets tái sử dụng ─────────────────────────────────────────────────

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
        border: Border.all(
            color: AppColors.primaryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping,
              color: AppColors.primaryOrange, size: 22),
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
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGray)),
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
          child: _checkboxTile(
              label: label, value: value, onChanged: onChanged),
        ),
        if (value)
          SizedBox(
            width: 72,
            child: TextFormField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'SL',
                isDense: true,
              ),
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
      fieldViewBuilder: (_, fieldCtrl, focusNode, onSubmit) {
        // Sync controller
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

  Widget _specTable({
    required List<String> headers,
    required String rowLabel,
    required List<TextEditingController> controllers,
  }) {
    return Table(
      border: TableBorder.all(
          color: AppColors.borderLight.withValues(alpha: 0.5), width: 0.8),
      columnWidths: const {0: IntrinsicColumnWidth()},
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.08)),
          children: headers
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ))
              .toList(),
        ),
        TableRow(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(rowLabel,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            ...controllers.map(
              (ctrl) => Padding(
                padding: const EdgeInsets.all(4),
                child: TextFormField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
