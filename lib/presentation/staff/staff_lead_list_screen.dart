import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/staff_providers.dart';
import '../../data/models/response/lead_response.dart';

class StaffLeadListScreen extends ConsumerWidget {
  const StaffLeadListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingOnly = ref.watch(staffLeadPendingOnlyFilter);
    final leadsAsync = ref.watch(staffLeadsProvider);

    return ColoredBox(
      color: AppColors.backgroundLight,
      child: Column(
        children: [
          // Filter toggle
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: !pendingOnly,
                  onSelected: (_) => ref
                      .read(staffLeadPendingOnlyFilter.notifier)
                      .state = false,
                  backgroundColor: AppColors.backgroundLight,
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: !pendingOnly ? AppColors.primaryOrange : AppColors.textGray,
                    fontWeight: !pendingOnly ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: !pendingOnly ? AppColors.primaryOrange : AppColors.borderLight,
                  ),
                  showCheckmark: false,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Chưa liên hệ'),
                  selected: pendingOnly,
                  onSelected: (_) => ref
                      .read(staffLeadPendingOnlyFilter.notifier)
                      .state = true,
                  backgroundColor: AppColors.backgroundLight,
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: pendingOnly ? AppColors.primaryOrange : AppColors.textGray,
                    fontWeight: pendingOnly ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: pendingOnly ? AppColors.primaryOrange : AppColors.borderLight,
                  ),
                  showCheckmark: false,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.invalidate(staffLeadsProvider);
                    ref.invalidate(staffUncontactedCountProvider);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: leadsAsync.when(
              data: (leads) {
                if (leads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.contact_phone_outlined,
                            size: 56,
                            color: AppColors.textGray.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          pendingOnly
                              ? 'Không có khách nào chưa được liên hệ'
                              : 'Chưa có lead nào',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(staffLeadsProvider);
                    ref.invalidate(staffUncontactedCountProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: leads.length,
                    itemBuilder: (_, i) => _LeadCard(lead: leads[i]),
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
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 40),
                      const SizedBox(height: 8),
                      Text(e.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.errorRed, fontSize: 13)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(staffLeadsProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lead Card ───────────────────────────────────────────────────────────────

class _LeadCard extends ConsumerStatefulWidget {
  final LeadResponse lead;
  const _LeadCard({required this.lead});

  @override
  ConsumerState<_LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends ConsumerState<_LeadCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.lead;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final needsAttention = !l.contacted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: needsAttention ? AppColors.warningAmber : AppColors.borderLight,
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
                    color: needsAttention
                        ? AppColors.warningAmber.withValues(alpha: 0.12)
                        : AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.contact_phone,
                    color: needsAttention
                        ? AppColors.warningAmber
                        : AppColors.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead #${l.id}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark),
                      ),
                      Text(
                        dateFmt.format(l.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: needsAttention
                        ? AppColors.warningAmber.withValues(alpha: 0.12)
                        : AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    needsAttention ? 'Chưa liên hệ' : 'Đã liên hệ',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: needsAttention
                            ? AppColors.warningAmber
                            : AppColors.successGreen),
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
                if (l.name != null && l.name!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Tên',
                    value: l.name!,
                  ),
                // Phone — tappable to dial
                GestureDetector(
                  onTap: () => _callPhone(l.phone),
                  child: _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Điện thoại',
                    value: l.phone,
                    valueColor: AppColors.infoBlue,
                    underline: true,
                  ),
                ),
                if (l.productName != null && l.productName!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Sản phẩm',
                    value: l.productName!,
                  ),
                if (l.specifications != null && l.specifications!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.tune_outlined,
                    label: 'Thông số',
                    value: l.specifications!,
                  ),
                if (l.note != null && l.note!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Ghi chú',
                    value: l.note!,
                  ),
              ],
            ),
          ),

          // Action button
          if (!l.contacted) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callPhone(l.phone),
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Gọi ngay', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.infoBlue,
                        side: const BorderSide(color: AppColors.infoBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _markContacted(context, ref),
                            icon: const Icon(Icons.phone_callback, size: 16),
                            label: const Text('Đã liên hệ',
                                style: TextStyle(fontSize: 13)),
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

  void _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _markContacted(BuildContext context, WidgetRef ref) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(staffActionsProvider.notifier)
          .markLeadContacted(widget.lead.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu đã liên hệ'),
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
}

// ─── Info Row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool underline;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.underline = false,
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
                fontWeight: FontWeight.w500,
                decoration:
                    underline ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
