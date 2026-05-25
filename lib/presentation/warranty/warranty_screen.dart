import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/service_providers.dart';
import '../../core/di/warranty_providers.dart';
import '../../data/models/response/warranty_response.dart';
import '../../domain/entities/warranty.dart';

const _kNavBarH = kBottomNavigationBarHeight;

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Bảo hành'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Xe của tôi'),
              Tab(text: 'Yêu cầu bảo hành'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_VehicleListTab(), _WarrantyRequestTab()],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: _kNavBarH),
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateRequestDialog(context, ref),
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Tạo yêu cầu'),
          ),
        ),
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateWarrantySheet(parentRef: ref),
    );
  }
}

// ─── Vehicle List Tab ─────────────────────────────────────────────────────────

class _VehicleListTab extends ConsumerWidget {
  const _VehicleListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);
    return vehiclesAsync.when(
      data: (vehicles) {
        if (vehicles.isEmpty) {
          return const _EmptyState(
            icon: Icons.directions_car_outlined,
            message: 'Chưa có xe nào được đăng ký',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myVehiclesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: vehicles.length,
            itemBuilder: (_, i) => _VehicleCard(vehicle: vehicles[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  static ({Color color, String text}) _warrantyStatus(Vehicle v) {
    if (v.warrantyExpiryDate == null) {
      return (color: AppColors.textGray, text: 'Không có bảo hành');
    }
    if (!v.isWarrantyActive) {
      return (color: AppColors.errorRed, text: 'Hết hạn bảo hành');
    }
    if (v.isWarrantyExpiringSoon) {
      return (color: AppColors.warningAmber, text: 'Sắp hết hạn');
    }
    return (color: AppColors.successGreen, text: 'Còn bảo hành');
  }

  @override
  Widget build(BuildContext context) {
    final status = _warrantyStatus(vehicle);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _showDigitalCard(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: AppColors.primaryNavy,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.text,
                      style: TextStyle(
                        fontSize: 11,
                        color: status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (vehicle.productName != null)
                _InfoRow(label: 'Mẫu xe', value: vehicle.productName!),
              _InfoRow(label: 'Số khung', value: vehicle.chassisNumber),
              if (vehicle.contractCode != null)
                _InfoRow(label: 'Mã hợp đồng', value: vehicle.contractCode!),
              if (vehicle.warrantyExpiryDate != null)
                _InfoRow(
                  label: 'Hết hạn BH',
                  value: vehicle.warrantyExpiryDate!,
                  valueColor: status.color,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Xem thẻ bảo hành',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: AppColors.primaryOrange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Honda-style digital warranty card
  void _showDigitalCard(BuildContext context) {
    final status = _warrantyStatus(vehicle);
    final qrData =
        'QUYENAUTO|${vehicle.plateNumber}|${vehicle.chassisNumber}|${vehicle.contractCode ?? ""}|${vehicle.warrantyExpiryDate ?? ""}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // card header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryNavy, const Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'THẺ BẢO HÀNH SỐ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status.color.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.text,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    if (vehicle.productName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          vehicle.productName!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // info + QR row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(
                          icon: Icons.confirmation_number,
                          label: 'Số khung',
                          value: vehicle.chassisNumber,
                        ),
                        if (vehicle.contractCode != null)
                          _DetailRow(
                            icon: Icons.article_outlined,
                            label: 'Hợp đồng',
                            value: vehicle.contractCode!,
                          ),
                        if (vehicle.warrantyExpiryDate != null)
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Hết hạn BH',
                            value: vehicle.warrantyExpiryDate!,
                            valueColor: status.color,
                          ),
                        if (vehicle.purchaseDate != null)
                          _DetailRow(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Ngày mua',
                            value: vehicle.purchaseDate!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 110,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primaryNavy,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Quét để xác minh',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Warranty Request Tab ─────────────────────────────────────────────────────

class _WarrantyRequestTab extends ConsumerWidget {
  const _WarrantyRequestTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warrantiesAsync = ref.watch(myWarrantiesProvider);
    return warrantiesAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.verified_user_outlined,
            message: 'Chưa có yêu cầu bảo hành nào',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myWarrantiesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (_, i) => _WarrantyCard(request: requests[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  final WarrantyRequestResponse request;
  const _WarrantyCard({required this.request});

  static const _statusMap = {
    'PENDING': ('Chờ xử lý', AppColors.warningAmber),
    'IN_PROGRESS': ('Đang xử lý', AppColors.infoBlue),
    'RESOLVED': ('Đã xử lý', AppColors.successGreen),
    'REJECTED': ('Từ chối', AppColors.errorRed),
  };

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) =
        _statusMap[request.status] ?? (request.status, AppColors.textGray);
    final fmt = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.build_rounded, color: statusColor, size: 22),
          ),
          title: Text(
            'BH #${request.id} — ${request.plateNumber}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              request.issueDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: [
            Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.scheduledDate != null)
                    _DetailRow(
                      icon: Icons.event,
                      label: 'Ngày hẹn',
                      value: request.scheduledDate!,
                    ),
                  if (request.technicianName != null)
                    _DetailRow(
                      icon: Icons.engineering,
                      label: 'Kỹ thuật viên',
                      value: request.technicianName!,
                    ),
                  if (request.result != null && request.result!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.check_circle_outline,
                      label: 'Kết quả',
                      value: request.result!,
                    ),
                  // Photo evidence
                  if (request.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Ảnh bằng chứng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: request.imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) => GestureDetector(
                          onTap: () => _viewImage(ctx, request.imageUrls[i]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: request.imageUrls[i],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.borderLight,
                                child: const Icon(
                                  Icons.image,
                                  color: AppColors.textGray,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.borderLight,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Service history timeline
                  if (request.logs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Lịch sử bảo dưỡng',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...request.logs.asMap().entries.map((entry) {
                      final i = entry.key;
                      final log = entry.value;
                      final isLast = i == request.logs.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // timeline line
                            Column(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: _logColor(log.action),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _logColor(
                                          log.action,
                                        ).withAlpha(80),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: AppColors.borderLight,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _logLabel(log.action),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _logColor(log.action),
                                      ),
                                    ),
                                    if (log.note != null &&
                                        log.note!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          log.note!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textGray,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        fmt.format(log.createdAt),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _logColor(String action) {
    switch (action) {
      case 'ASSIGN_TECHNICIAN':
        return AppColors.infoBlue;
      case 'UPDATE_RESULT':
        return AppColors.successGreen;
      case 'REJECT':
        return AppColors.errorRed;
      default:
        return AppColors.primaryNavy;
    }
  }

  String _logLabel(String action) {
    switch (action) {
      case 'ASSIGN_TECHNICIAN':
        return 'Phân công kỹ thuật viên';
      case 'UPDATE_RESULT':
        return 'Cập nhật kết quả';
      case 'REJECT':
        return 'Từ chối yêu cầu';
      default:
        return action;
    }
  }

  void _viewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: url),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Warranty Request Bottom Sheet ─────────────────────────────────────

class _CreateWarrantySheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _CreateWarrantySheet({required this.parentRef});

  @override
  ConsumerState<_CreateWarrantySheet> createState() =>
      _CreateWarrantySheetState();
}

class _CreateWarrantySheetState extends ConsumerState<_CreateWarrantySheet> {
  Vehicle? _selectedVehicle;
  final _issueController = TextEditingController();
  DateTime? _scheduledDate;
  final List<File> _images = [];
  bool _submitting = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked.map((x) => File(x.path))));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];
    final api = ref.read(apiServiceProvider);
    final urls = <String>[];
    for (final file in _images) {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'folder': 'warranty',
      });
      final res = await api.postMultipart<String>(
        ApiConstants.upload,
        formData: form,
        fromData: (json) => json as String,
      );
      if (res.data != null) urls.add(res.data!);
    }
    return urls;
  }

  Future<void> _submit() async {
    if (_selectedVehicle == null || _issueController.text.trim().isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final imageUrls = await _uploadImages();
      final scheduledDateStr = _scheduledDate != null
          ? DateFormat('yyyy-MM-dd').format(_scheduledDate!)
          : null;
      await ref
          .read(warrantyActionsProvider.notifier)
          .createRequest(
            vehicleId: _selectedVehicle!.id,
            issueDescription: _issueController.text.trim(),
            scheduledDate: scheduledDateStr,
            imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu bảo hành')),
        );
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
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(myVehiclesProvider);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Tạo yêu cầu bảo hành',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            vehiclesAsync.when(
              data: (vehicles) => DropdownButtonFormField<Vehicle>(
                value: _selectedVehicle,
                decoration: const InputDecoration(
                  labelText: 'Chọn xe',
                  border: OutlineInputBorder(),
                ),
                items: vehicles
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text('${v.plateNumber} — ${v.chassisNumber}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedVehicle = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Không tải được danh sách xe'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _issueController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả sự cố',
                hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFBDBDBD)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _scheduledDate != null
                            ? 'Ngày hẹn: ${dateFmt.format(_scheduledDate!)}'
                            : 'Chọn ngày hẹn bảo hành (tuỳ chọn)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _scheduledDate != null
                              ? AppColors.textDark
                              : AppColors.textGray,
                        ),
                      ),
                    ),
                    if (_scheduledDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _scheduledDate = null),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textGray,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Image upload
            if (_images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == _images.length) {
                      return _AddImageButton(onTap: _pickImage);
                    }
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _images[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              _AddImageButton(onTap: _pickImage, fullWidth: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Gửi yêu cầu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool fullWidth;
  const _AddImageButton({required this.onTap, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryOrange,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primaryOrange.withAlpha(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primaryOrange,
              size: fullWidth ? 28 : 22,
            ),
            if (fullWidth) ...[
              const SizedBox(height: 4),
              const Text(
                'Thêm ảnh bằng chứng',
                style: TextStyle(fontSize: 12, color: AppColors.primaryOrange),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textGray),
          const SizedBox(width: 6),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textGray, size: 48),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.errorRed),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
