import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/product_image_helper.dart';
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
    final resolvedImage = ProductImageHelper.resolve(product);
    final imageUrls = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : [resolvedImage];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with image ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: AppColors.textWhite,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    itemBuilder: (_, i) => Container(
                      color: AppColors.primaryNavy.withValues(alpha: 0.06),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[i],
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => _imageFallback(),
                      ),
                    ),
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: imageUrls.length,
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
              ),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (product.category.isNotEmpty)
                        _Badge(
                          label: _categoryLabel(product.category),
                          color: _categoryColor(product.category),
                        ),
                      if (product.inStock) ...[
                        const SizedBox(width: 8),
                        _Badge(
                          label: 'Còn hàng',
                          color: AppColors.successGreen,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Contact CTA
                  _ContactCTA(),
                  const SizedBox(height: 20),

                  // Specs (dimensions from API if available)
                  if (_hasSpecs(product)) ...[
                    _SpecsCard(product: product),
                    const SizedBox(height: 20),
                  ],

                  // Category features (real info from quyenauto.com)
                  _CategoryFeaturesCard(category: product.category),
                  const SizedBox(height: 20),

                  // Compatible chassis
                  _CompatibleChassisCard(
                    productName: product.name,
                    category: product.category,
                  ),
                  const SizedBox(height: 20),

                  // Description from API
                  if (product.description.isNotEmpty) ...[
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
                      product.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ISO badge
                  _IsoBadge(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.quotation, extra: product.id),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.textWhite,
        icon: const Icon(Icons.request_quote_outlined),
        label: const Text('Yêu cầu báo giá',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _imageFallback() => Container(
        color: AppColors.primaryNavy.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.local_shipping_outlined,
              size: 72, color: AppColors.primaryNavy),
        ),
      );

  bool _hasSpecs(Product p) =>
      p.truckType != null || p.length != null || p.width != null || p.height != null;

  String _categoryLabel(String cat) => switch (cat.toUpperCase()) {
        'REFRIGERATED' => 'Thùng Tải Lạnh',
        'INSULATED' => 'Thùng Bảo Ôn',
        'ENCLOSED' => 'Thùng Tải Kín',
        'CUSTOM' => 'Thiết Kế Riêng',
        _ => cat,
      };

  Color _categoryColor(String cat) => switch (cat.toUpperCase()) {
        'REFRIGERATED' => const Color(0xFF0D47A1),
        'INSULATED' => const Color(0xFF1B5E20),
        'ENCLOSED' => const Color(0xFF4A148C),
        'CUSTOM' => const Color(0xFFBF360C),
        _ => AppColors.primaryNavy,
      };
}

// ─── Badge ───────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Contact CTA ─────────────────────────────────────────────────────────────

class _ContactCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.phone_outlined,
              color: AppColors.textWhite, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liên hệ để nhận báo giá tốt nhất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Hotline: 0908 109 929 | Email: business@quyenauto.com',
                style: TextStyle(fontSize: 11, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Category Features Card ───────────────────────────────────────────────────

class _CategoryFeaturesCard extends StatelessWidget {
  final String category;
  const _CategoryFeaturesCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final data = _dataFor(category.toUpperCase());
    if (data == null) return const SizedBox.shrink();

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
          Row(children: [
            Icon(data.icon, color: data.color, size: 20),
            const SizedBox(width: 8),
            Text(
              data.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...data.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5, right: 10),
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                        height: 1.4,
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
  }

  static _FeaturesData? _dataFor(String cat) => switch (cat) {
        'REFRIGERATED' => _FeaturesData(
            title: 'Đặc điểm thùng tải lạnh',
            icon: Icons.ac_unit_outlined,
            color: const Color(0xFF0D47A1),
            features: [
              'Khung nhôm hợp kim cao cấp — nhẹ, bền, tối ưu tải trọng',
              'Vật liệu & công nghệ theo tiêu chuẩn châu Âu',
              'Sàn Inox chống trơn có lỗ thoát nước tiện vệ sinh',
              'Cửa hậu với bản lề & khóa Inox 304 cao cấp',
              'Đèn LED trần, còi báo động khẩn cấp',
              'Thanh khí lưu thông không khí tại vách trước',
              'Tùy chọn: móc treo thịt, vách ngăn, màn hơi lạnh, palet',
            ],
          ),
        'INSULATED' => _FeaturesData(
            title: 'Đặc điểm thùng bảo ôn',
            icon: Icons.thermostat_outlined,
            color: const Color(0xFF1B5E20),
            features: [
              'Cách nhiệt thụ động — không cần máy lạnh, tiết kiệm chi phí',
              'Giữ nhiệt ổn định quanh năm theo mùa vụ',
              'Thích hợp vận chuyển thủy hải sản ướp đá, rau củ quả',
              'Hỗ trợ hệ thống cấp oxy cho tôm cá sống theo yêu cầu',
              'Góc bo nhựa composite chống va đập',
              'Sàn chống trơn có lỗ thoát nước, bản lề Inox 304',
              'Đèn LED, còi báo động khẩn cấp tiêu chuẩn',
            ],
          ),
        'ENCLOSED' => _FeaturesData(
            title: 'Đặc điểm thùng tải kín',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF4A148C),
            features: [
              'Vật liệu nhôm cao cấp — tuổi thọ 12–15 năm nếu bảo dưỡng đúng',
              'Sàn Inox 430/304 dạng sóng chịu tải tốt',
              'Chống ẩm tuyệt đối, bảo vệ hàng hóa điện tử, nội thất',
              'Kích thước lớn, tải trọng cao theo từng chassis',
              'Cửa hậu bản lề Inox 304, có thể lắp thêm cửa hông',
              'Thang xếp thu gọn tiện lợi khi bốc dỡ hàng',
              'Đèn LED trần, còi báo động, gờ bảo vệ cao su góc sau',
            ],
          ),
        'CUSTOM' => _FeaturesData(
            title: 'Thiết kế theo yêu cầu',
            icon: Icons.design_services_outlined,
            color: const Color(0xFFBF360C),
            features: [
              'Đội ngũ kỹ sư chuyên nghiệp tư vấn & thiết kế tối ưu',
              'Đa dạng: PICKUP, VAN, xe gà, xe bán hàng, cánh dơi, sơ-mi',
              'Tích hợp tùy chọn: màn hình LED, máy phát điện, máy lạnh',
              'Chứng nhận ISO 9001:2015 — đảm bảo chất lượng quốc tế',
              'Xuất khẩu: Nhật Bản, Hàn Quốc, Úc, Nga, Thái Lan và nhiều nước',
              'Điều kiện giao hàng FOB và CIF theo yêu cầu',
              'Hỗ trợ hồ sơ kỹ thuật tiếng Anh cho khách hàng quốc tế',
            ],
          ),
        _ => null,
      };
}

class _FeaturesData {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> features;
  const _FeaturesData({
    required this.title,
    required this.icon,
    required this.color,
    required this.features,
  });
}

// ─── Compatible Chassis Card ──────────────────────────────────────────────────

class _CompatibleChassisCard extends StatelessWidget {
  final String productName;
  final String category;
  const _CompatibleChassisCard(
      {required this.productName, required this.category});

  @override
  Widget build(BuildContext context) {
    final brands = _brandsFor(productName, category.toUpperCase());
    if (brands.isEmpty) return const SizedBox.shrink();

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
          const Row(children: [
            Icon(Icons.directions_car_outlined,
                color: AppColors.primaryNavy, size: 20),
            SizedBox(width: 8),
            Text(
              'Chassis phù hợp',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...brands.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.brand,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: b.models
                        .map((m) => _ChassisChip(label: m))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<_BrandData> _brandsFor(String name, String cat) {
    final n = name.toLowerCase();
    final isLarge = n.contains('trên 6') ||
        n.contains('frr') ||
        n.contains('fsr') ||
        n.contains('fvr') ||
        n.contains('fl8') ||
        n.contains('fg8') ||
        n.contains('hd320');

    return switch (cat) {
      'REFRIGERATED' when isLarge => [
          _BrandData('ISUZU', ['FRR E5', 'FSR E5', 'FVR E5', 'FVM E5']),
          _BrandData('HINO', ['FL8J E4', 'FG8J E4', 'FC9J E4']),
          _BrandData('HYUNDAI', ['HD320 E4']),
          _BrandData('UD TRUCKS', ['CGE 350 E5']),
        ],
      'REFRIGERATED' => [
          _BrandData('ISUZU', ['QLR-QMR E5', 'NPR-NQR E5', 'QMR E5']),
          _BrandData('HINO', ['XZU730L E4', 'XZU720L E4', 'XZU650L E4']),
          _BrandData('HYUNDAI', ['Mighty 75S', '110S', 'N250', 'Porter H150']),
          _BrandData('FUSO', ['Canter 4.99', 'Canter 6.5']),
          _BrandData('SUZUKI', ['Carry E5', 'SK410K4']),
        ],
      'INSULATED' when isLarge => [
          _BrandData('ISUZU', ['FSR E5', 'FVR E4', 'FVM E4', 'FRR E4']),
          _BrandData('HINO', ['FL8J E4', 'FG8J E4', 'FC9J E4']),
          _BrandData('HYUNDAI', ['CDE 280', 'PKE 250']),
        ],
      'INSULATED' => [
          _BrandData('ISUZU', ['NQR E4', 'NPR E4', 'NMR E4', 'QKR E4']),
          _BrandData('HINO', ['XZU730L E4', 'XZU720L E4', 'XZU650L E4']),
          _BrandData('HYUNDAI', ['New Mighty N250', 'Porter 150']),
        ],
      'ENCLOSED' when isLarge => [
          _BrandData('ISUZU', ['FVM E4', 'FVR E4', 'FRR E4']),
          _BrandData('HINO', ['FL8J E4', 'FG8J E4', 'FC9J E4']),
        ],
      'ENCLOSED' => [
          _BrandData('ISUZU', ['NQR E4', 'NPR E4', 'NMR E4', 'QKR E4']),
          _BrandData('HINO', ['XZU730L E4', 'XZU720L E4', 'XZU650L E4']),
          _BrandData('KIA / THACO', ['K250', 'K200']),
          _BrandData('FUSO', ['Canter 4.99', 'Canter 6.5']),
        ],
      _ => [],
    };
  }
}

class _BrandData {
  final String brand;
  final List<String> models;
  const _BrandData(this.brand, this.models);
}

class _ChassisChip extends StatelessWidget {
  final String label;
  const _ChassisChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.primaryNavy.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
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
      if (product.truckType != null && product.truckType!.isNotEmpty)
        (label: 'Tải trọng', value: product.truckType!),
      if (product.length != null)
        (label: 'Chiều dài thùng',
            value: '${product.length!.toStringAsFixed(2)} m'),
      if (product.width != null)
        (label: 'Chiều rộng thùng',
            value: '${product.width!.toStringAsFixed(2)} m'),
      if (product.height != null)
        (label: 'Chiều cao thùng',
            value: '${product.height!.toStringAsFixed(2)} m'),
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
          const Row(children: [
            Icon(Icons.straighten_outlined,
                color: AppColors.primaryNavy, size: 20),
            SizedBox(width: 8),
            Text(
              'Thông số kỹ thuật',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...specs.map(
            (s) => Padding(
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ISO Badge ───────────────────────────────────────────────────────────────

class _IsoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.successGreen.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_outlined,
              color: AppColors.successGreen, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chứng nhận ISO 9001:2015',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successGreen,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Quyen Auto — 40+ năm kinh nghiệm chế tạo thùng xe',
                style: TextStyle(fontSize: 11, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
