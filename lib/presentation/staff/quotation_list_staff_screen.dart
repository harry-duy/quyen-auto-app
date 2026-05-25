import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/quotation_response.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Qu?n l� b�o gi�'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'B�o gi�'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Lead kh�ch'),
                    if (pendingLeadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingLeadCount',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
        body: const TabBarView(
          children: [_QuotationListTab(), StaffLeadListScreen()],
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
    'PENDING',
    'QUOTED',
    'ACCEPTED',
    'REJECTED',
  ];
  static const _filterLabels = [
    'T?t c?',
    'Ch? x? l�',
    '�� b�o gi�',
    '�� ch?t',
    'T? ch?i',
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
                        'Chua c� y�u c?u b�o gi�',
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
                      child: const Text('Th? l?i'),
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
    'PENDING' => AppColors.warningAmber,
    'QUOTED' => AppColors.statusQuoted,
    'ACCEPTED' => AppColors.successGreen,
    'REJECTED' => AppColors.errorRed,
    _ => AppColors.textGray,
  };

  Color get _statusBg => switch (widget.quotation.status) {
    'PENDING' => AppColors.warningAmber.withValues(alpha: 0.12),
    'QUOTED' => AppColors.statusQuotedBg,
    'ACCEPTED' => AppColors.successGreen.withValues(alpha: 0.1),
    'REJECTED' => AppColors.errorRed.withValues(alpha: 0.1),
    _ => AppColors.statusPendingBg,
  };

  String get _statusLabel => switch (widget.quotation.status) {
    'PENDING' => 'Ch? x? l�',
    'QUOTED' => '�� b�o gi�',
    'ACCEPTED' => '�� ch?t',
    'REJECTED' => 'T? ch?i',
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
                        'B�o gi� #${q.id}',
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
                  label: 'Kh�ch h�ng',
                  value: q.customerName ?? 'KH #${q.customerId}',
                ),
                if (q.customerPhone != null)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: '�i?n tho?i',
                    value: q.customerPhone!,
                    valueColor: AppColors.infoBlue,
                  ),
                if (q.vehicleModel != null)
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Lo?i xe',
                    value: q.vehicleModel!,
                  ),
                if (q.productName != null)
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'S?n ph?m',
                    value: q.productName!,
                  ),
                if (q.boxType != null)
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Lo?i th�ng',
                    value:
                        '${q.boxType}${q.boxCode != null ? ' (${q.boxCode})' : ''}',
                  ),
                if (q.chassisWidth != null)
                  _InfoRow(
                    icon: Icons.straighten_outlined,
                    label: 'Chi?u r?ng',
                    value: '${q.chassisWidth} mm',
                  ),
                if (q.weightRange != null)
                  _InfoRow(
                    icon: Icons.scale_outlined,
                    label: 'T?i tr?ng',
                    value: q.weightRange!,
                  ),
                if (q.quantity != null && q.quantity! > 1)
                  _InfoRow(
                    icon: Icons.format_list_numbered,
                    label: 'S? lu?ng',
                    value: '${q.quantity} xe',
                  ),
                if (q.note != null && q.note!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi ch�',
                    value: q.note!,
                  ),
                if (q.quotedPrice != null)
                  _InfoRow(
                    icon: Icons.price_check,
                    label: 'B�o gi�',
                    value: '${currFmt.format(q.quotedPrice!)} ?',
                    valueColor: AppColors.successGreen,
                    bold: true,
                  ),
              ],
            ),
          ),

          // Contact tracking section
          _ContactSection(quotation: q),

          // Action buttons
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () => _markContacted(context, ref),
                              icon: const Icon(Icons.phone_callback, size: 16),
                              label: const Text(
                                'Nh?n & li�n h?',
                                style: TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.successGreen,
                                side: const BorderSide(
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ),
                    ),
                  if (!q.isContacted) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmOrderDialog(context, ref),
                      icon: const Icon(Icons.fact_check, size: 16),
                      label: const Text(
                        'Ch?t & t?o don',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
            content: Text('�� nh?n x? l� b�o gi�'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('L?i: $e'),
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
        title: Text('Ch?t don #${widget.quotation.id}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gi� ch?t (VN�) *',
                  prefixText: '? ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui l�ng nh?p gi�';
                  final cleaned = v.replaceAll(',', '').replaceAll('.', '');
                  if (double.tryParse(cleaned) == null)
                    return 'Gi� kh�ng h?p l?';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: depositCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ti?n c?c (VN�)',
                  prefixText: '? ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final cleaned = v.replaceAll(',', '').replaceAll('.', '');
                  if (double.tryParse(cleaned) == null)
                    return 'Ti?n c?c kh�ng h?p l?';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: estimatedDateCtrl,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Ng�y d? ki?n ho�n th�nh',
                  hintText: 'yyyy-mm-dd',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (DateTime.tryParse(v.trim()) == null) {
                    return 'Ng�y kh�ng h?p l?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ghi ch� th?a thu?n (t�y ch?n)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('H?y'),
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
                      content: Text('�� ch?t don ${currFmt.format(price)} ?'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('L?i: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Ch?t don'),
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
                'Chua c� nh�n vi�n nh?n x? l�',
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
              '${quotation.contactedByName ?? 'Nh�n vi�n'} d� li�n h?'
              '${quotation.contactedAt != null ? ' � ${dateFmt.format(quotation.contactedAt!)}' : ''}',
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
