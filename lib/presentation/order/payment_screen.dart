import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderCode;

  const PaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.orderCode,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          if (request.url.contains('/payment/callback')) {
            _handlePaymentResult(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentResult(String url) {
    final uri = Uri.parse(url);
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    final isSuccess = responseCode == '00';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? AppColors.successGreen : AppColors.errorRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? 'Thanh toán thành công!' : 'Thanh toán thất bại',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess
                  ? 'Đơn hàng ${widget.orderCode} đã được xác nhận.'
                  : 'Vui lòng thử lại hoặc chọn phương thức khác.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(isSuccess);
              },
              child: Text(isSuccess ? 'Xong' : 'Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán ${widget.orderCode}'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            ),
        ],
      ),
    );
  }
}
