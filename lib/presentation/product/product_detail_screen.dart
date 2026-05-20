import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(id));
    return productAsync.when(
      data: (product) => _ProductDetailView(product: product),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                color: AppColors.errorRed, size: 48),
            const SizedBox(height: 12),
            const Text('Không thể tải sản phẩm'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(productDetailProvider(id)),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Detail View ─────────────────────────────────────────────────────────────

class _ProductDetailView extends StatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  final _pageController = PageController();

  Product get product => widget.product;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final hasImages = product.imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with image PageView ───────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: AppColors.textWhite,
            flexibleSpace: FlexibleSpaceBar(
              background: hasImages
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: product.imageUrls.length,
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: product.imageUrls[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, _, _) => _imageFallback(),
                          ),
                        ),
                        if (product.imageUrls.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: product.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  spacing: 6,
                                  activeDotColor: AppColors.primaryOrange,
                                  dotColor: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : _imageFallback(),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + category badge
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (product.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Price
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              AppColors.primaryOrange.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá tham khảo',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textGray),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.price > 0
                              ? 'Từ ${fmt.format(product.price)}'
                              : 'Liên hệ để nhận báo giá',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specs
                  _SpecsCard(product: product),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Chưa có mô tả cho sản phẩm này.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.quotation, extra: product.id),
              icon: const Icon(Icons.request_quote_outlined, size: 20),
              label: const Text(
                'Yêu cầu báo giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.textWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.primaryNavy.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(Icons.local_shipping_outlined,
            size: 72, color: AppColors.primaryNavy),
      ),
    );
  }
}

// ─── Specs Card ──────────────────────────────────────────────────────────────

class _SpecsCard extends StatelessWidget {
  final Product product;
  const _SpecsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final specs = <({String label, String value})>[
      if (product.category.isNotEmpty)
        (label: 'Phân loại', value: product.category),
      if (product.truckType != null && product.truckType!.isNotEmpty)
        (label: 'Tải trọng', value: product.truckType!),
      if (product.length != null)
        (label: 'Chiều dài', value: '${product.length!.toStringAsFixed(1)} m'),
      if (product.width != null)
        (label: 'Chiều rộng', value: '${product.width!.toStringAsFixed(1)} m'),
      if (product.height != null)
        (label: 'Chiều cao', value: '${product.height!.toStringAsFixed(1)} m'),
    ];
    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông số kỹ thuật',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...specs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(
                    child: Text(s.label,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textGray)),
                  ),
                  Text(s.value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                ]),
              )),
        ],
      ),
    );
  }
}
