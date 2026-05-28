import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/auth_providers.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/quotation_response.dart';
import 'staff_create_quotation_screen.dart';
import 'staff_lead_list_screen.dart';

class QuotationListStaffScreen extends ConsumerWidget {
  const QuotationListStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingLeadsAsync = ref.watch(staffLeadsProvider);
    final pendingLeadCount = pendingLeadsAsync.maybeWhen(
      data: (l) => l.where((e) => !e.contacted).length,
      orElse: () => 0,
    );

    // Phân biệt Manager vs Staff để dùng đúng provider
    final user = ref.watch(authProvider).valueOrNull;
    final isManager = user?.role.isManagerOrAbove ?? false;

    // Badge "Chờ duyệt": Manager xem tổng BG cần duyệt; Staff xem BG mình đã gửi duyệt
    final pendingApprovalCount = isManager
        ? ref
            .watch(managerPendingApprovalProvider)
            .maybeWhen(data: (l) => l.length, orElse: () => 0)
        : ref
            .watch(staffOwnPendingApprovalProvider)
            .maybeWhen(data: (l) => l.length, orElse: () => 0);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Quản lý Báo Giá'),
          actions: [
            // Nút tạo BG mới
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Tạo Báo Giá',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const StaffCreateQuotationScreen()),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Báo giá'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chờ duyệt'),
                    if (pendingApprovalCount > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(count: pendingApprovalCount),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Lead khách'),
                    if (pendingLeadCount > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(count: pendingLeadCount),
                    ],
                  ],
                ),
              ),
            ],
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textGray,
            indicatorColor: AppColors.primaryOrange,
          ),
        ),
        body: TabBarView(
          children: [
            const _QuotationListTab(),
            // Tab "Chờ duyệt": Manager thấy tất cả + nút duyệt/từ chối;
            // Staff chỉ thấy BG của mình đang chờ (không có nút duyệt).
            isManager ? const _ManagerPendingTab() : const _StaffOwnPendingTab(),
            const StaffLeadListScreen(),
          ],
        ),
      ),
    );
  }
}

// --- Quotation List Tab -------------------------------------------------------

class _QuotationListTab extends ConsumerWidget {
  const _QuotationListTab();

  static const _filters = <String?>[
    null,
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'SENT',
    'PENDING',
    'ACCEPTED',
    'REJECTED',
  ];
  static const _filterLabels = [
    'Tất cả',
    'Nháp',
    'Chờ duyệt',
    'Đã duyệt',
    'Đã gửi KH',
    'Chờ xử lý',
    'Đã chốt',
    'Từ chối',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(staffQuotationStatusFilter);
    final quotationsAsync = ref.watch(staffQuotationListProvider);

    return Column(
      children: [
        // Status filter chips
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ...List.generate(_filters.length, (i) {
                  final isSelected = currentFilter == _filters[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabels[i]),
                      selected: isSelected,
                      onSelected: (_) =>
                          ref.read(staffQuotationStatusFilter.notifier).state =
                              _filters[i],
                      backgroundColor: AppColors.backgroundLight,
                      selectedColor: AppColors.primaryOrange.withValues(
                        alpha: 0.15,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.textGray,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.invalidate(staffQuotationListProvider);
                    ref.invalidate(staffUncontactedCountProvider);
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: quotationsAsync.when(
            data: (quotations) {
              if (quotations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.request_quote_outlined,
                        size: 56,
                        color: AppColors.textGray,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có yêu cầu báo giá',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(staffQuotationListProvider);
                  ref.invalidate(staffUncontactedCountProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: quotations.length,
                  itemBuilder: (_, i) =>
                      _QuotationCard(quotation: quotations[i]),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.errorRed,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(staffQuotationListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Quotation Card ----------------------------------------------------------

class _QuotationCard extends ConsumerStatefulWidget {
  final StaffQuotationResponse quotation;
  const _QuotationCard({required this.quotation});

  @override
  ConsumerState<_QuotationCard> createState() => _QuotationCardState();
}

class _QuotationCardState extends ConsumerState<_QuotationCard> {
  bool _loading = false;

  Color get _statusColor => switch (widget.quotation.status) {
    'DRAFT' => AppColors.textGray,
    'PENDING_APPROVAL' => AppColors.warningAmber,
    'APPROVED' => AppColors.infoBlue,
    'SENT' => AppColors.statusQuoted,
    'PENDING' => AppColors.warningAmber,
    'QUOTED' => AppColors.statusQuoted,
    'ACCEPTED' => AppColors.successGreen,
    'REJECTED' => AppColors.errorRed,
    _ => AppColors.textGray,
  };

  Color get _statusBg => switch (widget.quotation.status) {
    'DRAFT' => AppColors.backgroundLight,
    'PENDING_APPROVAL' => AppColors.warningAmber.withValues(alpha: 0.12),
    'APPROVED' => AppColors.infoBlue.withValues(alpha: 0.1),
    'SENT' => AppColors.statusQuotedBg,
    'PENDING' => AppColors.warningAmber.withValues(alpha: 0.12),
    'QUOTED' => AppColors.statusQuotedBg,
    'ACCEPTED' => AppColors.successGreen.withValues(alpha: 0.1),
    'REJECTED' => AppColors.errorRed.withValues(alpha: 0.1),
    _ => AppColors.statusPendingBg,
  };

  String get _statusLabel => switch (widget.quotation.status) {
    'DRAFT' => 'Nháp',
    'PENDING_APPROVAL' => 'Chờ Manager duyệt',
    'APPROVED' => 'Đã duyệt',
    'SENT' => 'Đã gửi KH',
    'PENDING' => 'Chờ xử lý',
    'QUOTED' => 'Đã báo giá',
    'ACCEPTED' => 'Đã chốt',
    'REJECTED' => 'Từ chối',
    _ => widget.quotation.status,
  };

  @override
  Widget build(BuildContext context) {
    final q = widget.quotation;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final currFmt = NumberFormat('#,###', 'vi_VN');

    // Highlight uncontacted pending cards
    final needsAttention = q.isPending && !q.isContacted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: needsAttention
              ? AppColors.warningAmber
              : AppColors.borderLight,
          width: needsAttention ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.request_quote,
                    color: _statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Báo giá #${q.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        dateFmt.format(q.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 14, endIndent: 14),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer info
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Khách hàng',
                  value: q.customerName ?? 'KH #${q.customerId}',
                ),
                if (q.customerPhone != null)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Điện thoại',
                    value: q.customerPhone!,
                    valueColor: AppColors.infoBlue,
                  ),
                if (q.vehicleModel != null)
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Loại xe',
                    value: q.vehicleModel!,
                  ),
                if (q.productName != null)
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Sản phẩm',
                    value: q.productName!,
                  ),
                if (q.boxType != null)
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Loại thùng',
                    value:
                        '${q.boxType}${q.boxCode != null ? ' (${q.boxCode})' : ''}',
                  ),
                if (q.chassisWidth != null)
                  _InfoRow(
                    icon: Icons.straighten_outlined,
                    label: 'Chiều rộng',
                    value: '${q.chassisWidth} mm',
                  ),
                if (q.weightRange != null)
                  _InfoRow(
                    icon: Icons.scale_outlined,
                    label: 'Tải trọng',
                    value: q.weightRange!,
                  ),
                if (q.quantity != null && q.quantity! > 1)
                  _InfoRow(
                    icon: Icons.format_list_numbered,
                    label: 'Số lượng',
                    value: '${q.quantity} xe',
                  ),
                if (q.note != null && q.note!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi chú',
                    value: q.note!,
                  ),
                if (q.quotedPrice != null)
                  _InfoRow(
                    icon: Icons.price_check,
                    label: 'Báo giá',
                    value: '${currFmt.format(q.quotedPrice!)} ₫',
                    valueColor: AppColors.successGreen,
                    bold: true,
                  ),
              ],
            ),
          ),

          // Contact tracking section
          _ContactSection(quotation: q),

          // Action buttons — flow cũ (PENDING)
          if (q.isPending) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  if (!q.isContacted)
                    Expanded(
                      child: _loading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _markContacted(context, ref),
                              icon: const Icon(Icons.phone_callback, size: 16),
                              label: const Text('Nhận & liên hệ',
                                  style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.successGreen,
                                side: const BorderSide(
                                    color: AppColors.successGreen),
                              ),
                            ),
                    ),
                  if (!q.isContacted) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showConfirmOrderDialog(context, ref),
                      icon: const Icon(Icons.fact_check, size: 16),
                      label: const Text('Chốt & tạo đơn',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons — flow mới
          if (q.isDraft) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : () => _submitForApproval(context, ref),
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Gửi Manager duyệt',
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warningAmber,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],

          if (q.isApproved) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : () => _sendToCustomer(context, ref),
                  icon: const Icon(Icons.forward_to_inbox, size: 16),
                  label: const Text('Gửi Báo Giá cho KH',
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.infoBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitForApproval(BuildContext context, WidgetRef ref) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .submitForApproval(widget.quotation.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã gửi Manager duyệt!'),
          backgroundColor: AppColors.successGreen,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendToCustomer(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Gửi Báo Giá cho KH?'),
        content: Text(
          'Xác nhận đã gửi báo giá #${widget.quotation.id} cho KH '
          '${widget.quotation.customerName ?? ''} qua App/Zalo/Email?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận đã gửi')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .sendQuotationToCustomer(widget.quotation.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã đánh dấu gửi KH!'),
          backgroundColor: AppColors.successGreen,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markContacted(BuildContext context, WidgetRef ref) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .markQuotationContacted(widget.quotation.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã nhận xử lý báo giá'),
            backgroundColor: AppColors.successGreen,
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
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showConfirmOrderDialog(BuildContext context, WidgetRef ref) {
    final priceCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    final estimatedDateCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final currFmt = NumberFormat('#,###', 'vi_VN');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chốt đơn #${widget.quotation.id}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá chốt (VNĐ) *',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                  final cleaned = v.replaceAll(',', '').replaceAll('.', '');
                  if (double.tryParse(cleaned) == null)
                    return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: depositCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiền cọc (VNĐ)',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final cleaned = v.replaceAll(',', '').replaceAll('.', '');
                  if (double.tryParse(cleaned) == null)
                    return 'Tiền cọc không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: estimatedDateCtrl,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Ngày dự kiến hoàn thành',
                  hintText: 'yyyy-mm-dd',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (DateTime.tryParse(v.trim()) == null) {
                    return 'Ngày không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ghi chú thỏa thuận (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final cleaned = priceCtrl.text
                  .replaceAll(',', '')
                  .replaceAll('.', '');
              final price = double.parse(cleaned);
              final depositText = depositCtrl.text
                  .replaceAll(',', '')
                  .replaceAll('.', '')
                  .trim();
              final deposit = depositText.isEmpty
                  ? null
                  : double.parse(depositText);
              final estimatedDate = estimatedDateCtrl.text.trim().isEmpty
                  ? null
                  : DateTime.parse(estimatedDateCtrl.text.trim());
              Navigator.pop(ctx);
              try {
                await ref
                    .read(staffActionsProvider.notifier)
                    .confirmQuotationOrder(
                      widget.quotation.id.toString(),
                      price,
                      deposit,
                      estimatedDate,
                      noteCtrl.text.isEmpty ? null : noteCtrl.text,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chốt đơn ${currFmt.format(price)} ₫'),
                      backgroundColor: AppColors.successGreen,
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
            child: const Text('Chốt đơn'),
          ),
        ],
      ),
    );
  }
}

// --- Contact Section ---------------------------------------------------------

class _ContactSection extends StatelessWidget {
  final StaffQuotationResponse quotation;
  const _ContactSection({required this.quotation});

  @override
  Widget build(BuildContext context) {
    if (!quotation.isContacted) {
      if (!quotation.isPending) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.warningAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.warningAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: AppColors.warningAmber,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Chưa có nhân viên nhận xử lý',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.warningAmber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${quotation.contactedByName ?? 'Nhân viên'} đã liên hệ'
              '${quotation.contactedAt != null ? ' lúc ${dateFmt.format(quotation.contactedAt!)}' : ''}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.successGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Info Row ----------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textGray),
          const SizedBox(width: 6),
          SizedBox(
            width: 80,
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
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge widget ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.errorRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Tab: Chờ duyệt — Manager view (tất cả BG + nút Duyệt/Từ chối) ──────────

class _ManagerPendingTab extends ConsumerWidget {
  const _ManagerPendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(managerPendingApprovalProvider);

    return listAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 56, color: AppColors.successGreen),
                SizedBox(height: 12),
                Text('Không có báo giá nào chờ duyệt',
                    style: TextStyle(color: AppColors.textGray, fontSize: 14)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(managerPendingApprovalProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => _ApprovalCard(quotation: items[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
            const SizedBox(height: 8),
            Text(e.toString(),
                style: const TextStyle(color: AppColors.errorRed)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(managerPendingApprovalProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab: Chờ duyệt — Staff view (BG của mình đang chờ Manager) ──────────────

class _StaffOwnPendingTab extends ConsumerWidget {
  const _StaffOwnPendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(staffOwnPendingApprovalProvider);

    return listAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty,
                    size: 56, color: AppColors.textGray),
                SizedBox(height: 12),
                Text('Chưa có báo giá nào gửi duyệt',
                    style: TextStyle(color: AppColors.textGray, fontSize: 14)),
                SizedBox(height: 6),
                Text(
                  'Tạo báo giá và nhấn "Gửi Manager duyệt" để xem ở đây',
                  style: TextStyle(color: AppColors.textGray, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(staffOwnPendingApprovalProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => _PendingInfoCard(quotation: items[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed, size: 40),
            const SizedBox(height: 8),
            Text(e.toString(),
                style: const TextStyle(color: AppColors.errorRed)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(staffOwnPendingApprovalProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card đọc-chỉ: BG đang chờ Manager duyệt (Staff view) ────────────────────

class _PendingInfoCard extends StatelessWidget {
  final StaffQuotationResponse quotation;
  const _PendingInfoCard({required this.quotation});

  @override
  Widget build(BuildContext context) {
    final q = quotation;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warningAmber.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pending_actions,
                      color: AppColors.warningAmber, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Báo giá #${q.id}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text(dateFmt.format(q.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGray)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Chờ Manager',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningAmber)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Khách hàng',
                    value: q.customerName ?? 'KH #${q.customerId}'),
                if (q.customerPhone != null)
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Điện thoại',
                      value: q.customerPhone!,
                      valueColor: AppColors.infoBlue),
                if (q.vehicleModel != null)
                  _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Loại xe',
                      value: q.vehicleModel!),
                if (q.isNewProductRequest == true)
                  _InfoRow(
                      icon: Icons.new_releases_outlined,
                      label: 'SP mới',
                      value: q.newProductDescription ?? '—',
                      valueColor: AppColors.warningAmber),
                if (q.productName != null)
                  _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Sản phẩm',
                      value: q.productName!),
                if (q.note != null && q.note!.isNotEmpty)
                  _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Ghi chú',
                      value: q.note!),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.warningAmber.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: AppColors.warningAmber),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Đang chờ Manager xem xét và duyệt',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.warningAmber),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Approval Card (Manager duyệt / từ chối) ─────────────────────────────────

class _ApprovalCard extends ConsumerStatefulWidget {
  final StaffQuotationResponse quotation;
  const _ApprovalCard({required this.quotation});

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.quotation;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warningAmber.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pending_actions,
                      color: AppColors.warningAmber, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Báo giá #${q.id}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text(dateFmt.format(q.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGray)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Chờ duyệt',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningAmber)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, indent: 14, endIndent: 14),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Khách hàng',
                    value: q.customerName ?? 'KH #${q.customerId}'),
                if (q.customerPhone != null)
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Điện thoại',
                      value: q.customerPhone!,
                      valueColor: AppColors.infoBlue),
                if (q.staffName != null)
                  _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Nhân viên',
                      value: q.staffName!),
                if (q.vehicleModel != null)
                  _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Loại xe',
                      value: q.vehicleModel!),
                if (q.isNewProductRequest == true)
                  _InfoRow(
                      icon: Icons.new_releases_outlined,
                      label: 'SP mới',
                      value: q.newProductDescription ?? '—',
                      valueColor: AppColors.warningAmber),
                if (q.productName != null)
                  _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Sản phẩm',
                      value: q.productName!),
                if (q.note != null && q.note!.isNotEmpty)
                  _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Ghi chú',
                      value: q.note!),
              ],
            ),
          ),

          // Approve / Reject buttons
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: _loading
                ? const Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2)))
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reject(context),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Từ chối',
                              style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorRed,
                            side:
                                const BorderSide(color: AppColors.errorRed),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approve(context),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Duyệt BG',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(BuildContext context) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Duyệt báo giá #${widget.quotation.id}'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Ghi chú (tuỳ chọn)',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white),
              child: const Text('Xác nhận duyệt')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(staffActionsProvider.notifier).managerApproveQuotation(
            widget.quotation.id.toString(),
            noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã duyệt báo giá!'),
          backgroundColor: AppColors.successGreen,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject(BuildContext context) async {
    final noteCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Từ chối báo giá #${widget.quotation.id}'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Lý do từ chối *',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white),
              child: const Text('Xác nhận từ chối')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await ref.read(staffActionsProvider.notifier).managerRejectQuotation(
            widget.quotation.id.toString(),
            noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã từ chối báo giá'),
          backgroundColor: AppColors.warningAmber,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
