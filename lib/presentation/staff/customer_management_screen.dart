import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/management_providers.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/user.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final query = ref.watch(customerSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(customerListProvider),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCustomerDialog(context, ref),
        tooltip: 'Tạo tài khoản khách hàng',
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT, email…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(customerSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
              ),
              onChanged: (v) =>
                  ref.read(customerSearchQueryProvider.notifier).state =
                      v.trim(),
            ),
          ),
          const Divider(height: 1),

          // ── Customer list ────────────────────────────────────────────
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          query.isNotEmpty
                              ? Icons.search_off
                              : Icons.people_outline,
                          color: AppColors.textGray,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          query.isNotEmpty
                              ? 'Không tìm thấy "$query"'
                              : 'Chưa có khách hàng nào',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 14),
                        ),
                        if (query.isEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCreateCustomerDialog(context, ref),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Tạo tài khoản đầu tiên'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(customerListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: customers.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) => _CustomerTile(
                      customer: customers[i],
                      onToggle: () async {
                        final confirmed = await _confirmToggle(
                            context, customers[i]);
                        if (confirmed) {
                          try {
                            await ref
                                .read(managementActionsProvider.notifier)
                                .toggleCustomerActive(customers[i].id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(customers[i].isActive
                                      ? 'Đã vô hiệu hóa tài khoản'
                                      : 'Đã kích hoạt tài khoản'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e
                                      .toString()
                                      .replaceAll('Exception:', '')
                                      .trim()),
                                  backgroundColor: AppColors.errorRed,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.errorRed, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      e.toString().replaceAll('Exception:', '').trim(),
                      style:
                          const TextStyle(color: AppColors.errorRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(customerListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmToggle(BuildContext context, User customer) async {
    final action = customer.isActive ? 'vô hiệu hóa' : 'kích hoạt';
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('${action.toUpperCase()} tài khoản?'),
            content: Text(
                'Bạn muốn $action tài khoản của ${customer.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: customer.isActive
                    ? ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorRed)
                    : null,
                child: Text(action[0].toUpperCase() + action.substring(1)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ─── Create Customer Dialog ───────────────────────────────────────────────────

Future<void> _showCreateCustomerDialog(
    BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreateCustomerSheet(widgetRef: ref),
  );
}

class _CreateCustomerSheet extends ConsumerStatefulWidget {
  final WidgetRef widgetRef;
  const _CreateCustomerSheet({required this.widgetRef});

  @override
  ConsumerState<_CreateCustomerSheet> createState() =>
      _CreateCustomerSheetState();
}

class _CreateCustomerSheetState
    extends ConsumerState<_CreateCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _autoGeneratePassword() {
    // Sinh mật khẩu từ SĐT + 3 ký tự đặc biệt để dễ nhớ
    final phone = _phoneCtrl.text.trim();
    if (phone.length >= 4) {
      final pass = 'QA${phone.substring(phone.length - 4)}@auto';
      setState(() => _passCtrl.text = pass);
    } else {
      setState(() => _passCtrl.text = 'QAuto@2024');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await ref.read(managementActionsProvider.notifier).createCustomer(
            fullName: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            password: _passCtrl.text,
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            note: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Đã tạo tài khoản cho ${_nameCtrl.text.trim()}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add,
                        color: Colors.green, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tạo tài khoản khách hàng',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text('Sau khi chốt hợp đồng',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textGray)),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Khách hàng sẽ dùng SĐT + mật khẩu này để đăng nhập '
                        'và xem tiến độ đơn hàng, bảo hành.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // Full name
                TextFormField(
                  controller: _nameCtrl,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: !_loading,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),

                // Email (optional)
                TextFormField(
                  controller: _emailCtrl,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (không bắt buộc)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return Validators.email(v.trim());
                  },
                ),
                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  enabled: !_loading,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePass = !_obscurePass),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _autoGeneratePassword,
                          child: const Text('Tự sinh',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    helperText: 'Tối thiểu 6 ký tự',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                    if (v.length < 6) return 'Tối thiểu 6 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Internal note
                TextFormField(
                  controller: _noteCtrl,
                  enabled: !_loading,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú nội bộ (không bắt buộc)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    hintText: 'VD: Hợp đồng #123, xe Isuzu 3.5T',
                  ),
                ),
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                        _loading ? 'Đang tạo…' : 'Tạo tài khoản'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Customer Tile ────────────────────────────────────────────────────────────

class _CustomerTile extends StatelessWidget {
  final User customer;
  final VoidCallback onToggle;

  const _CustomerTile({required this.customer, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: customer.isActive
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.15),
        backgroundImage: customer.avatarUrl != null
            ? NetworkImage(customer.avatarUrl!)
            : null,
        child: customer.avatarUrl == null
            ? Text(
                customer.fullName.isNotEmpty
                    ? customer.fullName[0].toUpperCase()
                    : 'K',
                style: TextStyle(
                  color:
                      customer.isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              )
            : null,
      ),
      title: Row(children: [
        Expanded(
          child: Text(
            customer.fullName,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: customer.isActive
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            customer.isActive ? 'Hoạt động' : 'Đã khóa',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color:
                  customer.isActive ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ]),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.phone_outlined,
                size: 12, color: AppColors.textGray),
            const SizedBox(width: 4),
            Text(customer.phone,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textGray)),
          ]),
          if (customer.email != null) ...[
            const SizedBox(height: 1),
            Row(children: [
              const Icon(Icons.email_outlined,
                  size: 12, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(customer.email!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGray)),
            ]),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.textGray),
        onSelected: (v) {
          if (v == 'toggle') onToggle();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'toggle',
            child: Row(children: [
              Icon(
                customer.isActive ? Icons.block : Icons.check_circle,
                size: 18,
                color: customer.isActive
                    ? AppColors.errorRed
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(customer.isActive
                  ? 'Vô hiệu hóa'
                  : 'Kích hoạt lại'),
            ]),
          ),
        ],
      ),
      isThreeLine: customer.email != null,
    );
  }
}
