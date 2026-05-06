import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _phoneCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool  _obscurePass   = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).login(
      phone:    _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    ref.read(authProvider).when(
      data: (user) {
        if (user != null) context.go(AppRoutes.home);
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

  // ── Zalo OAuth ─────────────────────────────────────────────────────────────
  void _loginWithZalo() {
    // TODO: Mở WebView Zalo OAuth, lấy code rồi gọi authProvider.loginWithZalo(code)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zalo OAuth — Coming Soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Logo ──────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'QA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────
                const Text(
                  'Quyen Auto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chào mừng trở lại',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.textGray),
                ),
                const SizedBox(height: 40),

                // ── SĐT ──────────────────────────────────────────────────
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '0901234567',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────────────
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textGray,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),

                // ── Quên mật khẩu ─────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : () {
                      // TODO: navigate to forgot password
                    },
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Đăng nhập ─────────────────────────────────────────────
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.login),
                ),
                const SizedBox(height: 12),

                // ── Divider ───────────────────────────────────────────────
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('hoặc', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 12),

                // ── Đăng nhập Zalo ────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _loginWithZalo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0068FF),
                    side: const BorderSide(color: Color(0xFF0068FF), width: 1.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text(
                    'Đăng nhập bằng Zalo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Đăng ký ──────────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Chưa có tài khoản?',
                      style: TextStyle(color: AppColors.textGray)),
                  TextButton(
                    onPressed: isLoading ? null : () => context.push(AppRoutes.register),
                    child: const Text(AppStrings.register),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
