import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/router/staff_router.dart';

/// Man hinh nhap ma OTP xac minh email.
/// Duoc hien sau dang ky khi user co email.
/// Co the bo qua — user van dung duoc app nhung se co banner nhac.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  // 6 o nhap tung chu so
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focuses = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;
  int _countdown = 300; // 5 phut tinh bang giay
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focuses) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  String get _countdownText {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _code =>
      _controllers.map((c) => c.text).join();

  // ── Xac minh ────────────────────────────────────────────────────────────────

  Future<void> _verify() async {
    final code = _code;
    if (code.length < 6) {
      _showError('Vui lòng nhập đủ 6 chữ số');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verifyOtp(code);
      if (!mounted) return;
      // Xac minh thanh cong → chuyen ve trang chu
      final user = ref.read(authProvider).valueOrNull;
      final home = (user?.role.isStaffOrAbove ?? false)
          ? StaffRoutes.home
          : AppRoutes.home;
      context.go(home);
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Gui lai ─────────────────────────────────────────────────────────────────

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref.read(authProvider.notifier).resendOtp();
      if (!mounted) return;
      _startCountdown();
      // Xoa cac o nhap
      for (final c in _controllers) {
        c.clear();
      }
      _focuses[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lại mã OTP vào email của bạn'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Xu ly nhap tung o ───────────────────────────────────────────────────────

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focuses[index + 1].requestFocus();
    }
    // Tu dong xac minh khi nhap du 6 chu so
    if (_code.length == 6) _verify();
    setState(() {});
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focuses[index - 1].requestFocus();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final email = user?.email ?? 'email của bạn';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Xác minh email'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Bo qua → chuyen ve trang chu
            final home = (user?.role.isStaffOrAbove ?? false)
                ? StaffRoutes.home
                : AppRoutes.home;
            context.go(home);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 36, color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 20),

              // Tieu de
              const Text(
                'Nhập mã xác minh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chúng tôi đã gửi mã 6 chữ số đến\n$email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 6 o nhap
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildDigitBox(i)),
              ),
              const SizedBox(height: 28),

              // Countdown + gui lai
              _countdown > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.textGray),
                        const SizedBox(width: 4),
                        Text(
                          'Mã hết hạn sau $_countdownText',
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 13),
                        ),
                      ],
                    )
                  : TextButton.icon(
                      onPressed: _resending ? null : _resend,
                      icon: _resending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh, size: 16),
                      label: const Text('Gửi lại mã'),
                    ),
              const SizedBox(height: 16),

              // Nut Xac minh
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_loading || _code.length < 6) ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Xác minh'),
                ),
              ),
              const SizedBox(height: 12),

              // Bo qua
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        final home = (user?.role.isStaffOrAbove ?? false)
                            ? StaffRoutes.home
                            : AppRoutes.home;
                        context.go(home);
                      },
                child: const Text(
                  'Bỏ qua, xác minh sau',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) => _onKeyDown(index, e),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focuses[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: !_loading,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isFilled
                    ? AppColors.primaryNavy
                    : AppColors.borderLight,
                width: isFilled ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryNavy, width: 2),
            ),
            filled: true,
            fillColor: isFilled
                ? AppColors.primaryNavy.withAlpha(10)
                : Colors.white,
          ),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
          onChanged: (v) => _onChanged(index, v),
        ),
      ),
    );
  }
}
