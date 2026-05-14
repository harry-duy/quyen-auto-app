import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _phoneCtrl       = TextEditingController();
  final _fullNameCtrl    = TextEditingController();
  final _companyCtrl     = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  // FocusNodes để chuyển focus khi nhấn next
  final _phoneFocus    = FocusNode();
  final _nameFocus     = FocusNode();
  final _companyFocus  = FocusNode();
  final _emailFocus    = FocusNode();
  final _passFocus     = FocusNode();
  final _confirmFocus  = FocusNode();

  @override
  void dispose() {
    _phoneCtrl.dispose();    _phoneFocus.dispose();
    _fullNameCtrl.dispose(); _nameFocus.dispose();
    _companyCtrl.dispose();  _companyFocus.dispose();
    _emailCtrl.dispose();    _emailFocus.dispose();
    _passwordCtrl.dispose(); _passFocus.dispose();
    _confirmCtrl.dispose();  _confirmFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).register(
      phone:       _phoneCtrl.text.trim(),
      fullName:    _fullNameCtrl.text.trim(),
      email:       _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      companyName: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      password:    _passwordCtrl.text,
    );

    if (!mounted) return;

    ref.read(authProvider).when(
      data: (user) {
        if (user != null) {
          // Co email va chua xac minh → hien man OTP
          if (!user.emailVerified && user.email != null) {
            context.go(AppRoutes.verifyOtp);
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.register),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Header ───────────────────────────────────────────────
                const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Điền thông tin bên dưới để đăng ký',
                  style: TextStyle(fontSize: 14, color: AppColors.textGray),
                ),
                const SizedBox(height: 28),

                // ── SĐT ──────────────────────────────────────────────────
                TextFormField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _nameFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    hintText: '0901234567',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),

                // ── Họ tên ───────────────────────────────────────────────
                TextFormField(
                  controller: _fullNameCtrl,
                  focusNode: _nameFocus,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _companyFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    hintText: 'Nguyễn Văn A',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => Validators.required(v, 'Họ tên'),
                ),
                const SizedBox(height: 14),

                // ── Tên công ty (optional) ────────────────────────────────
                TextFormField(
                  controller: _companyCtrl,
                  focusNode: _companyFocus,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Tên công ty',
                    hintText: 'Để trống nếu không có',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  // không bắt buộc
                ),
                const SizedBox(height: 14),

                // ── Email (optional) ──────────────────────────────────────
                TextFormField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _passFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@email.com (tuỳ chọn)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 14),

                // ── Mật khẩu ─────────────────────────────────────────────
                TextFormField(
                  controller: _passwordCtrl,
                  focusNode: _passFocus,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: '${AppStrings.password} *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textGray,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 14),

                // ── Xác nhận mật khẩu ────────────────────────────────────
                TextFormField(
                  controller: _confirmCtrl,
                  focusNode: _confirmFocus,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textGray,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  // ← Realtime validate: khớp với password field
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                    if (v != _passwordCtrl.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Đăng ký ──────────────────────────────────────────────
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.register),
                ),
                const SizedBox(height: 16),

                // ── Đã có tài khoản ───────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Đã có tài khoản?',
                      style: TextStyle(color: AppColors.textGray)),
                  TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: const Text(AppStrings.login),
                  ),
                ]),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
