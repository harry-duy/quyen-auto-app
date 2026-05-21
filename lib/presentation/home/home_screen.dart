import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../order/order_list_screen.dart';
import '../product/product_list_screen.dart';
import '../profile/profile_screen.dart';
import '../warranty/warranty_screen.dart';
import '../widgets/shortcut_card.dart';

// ─── Static data from quyenauto.com ──────────────────────────────────────────

const _kLogoUrl =
    'https://quyenauto.com/wp-content/uploads/2018/05/logo_quyenauto.png';

const _kHeroBanners = [
  _HeroBanner(
    imageUrl: 'https://quyenauto.com/wp-content/uploads/2022/04/Banner-F1N.jpg',
    title: 'Thùng Xe Tải Lạnh',
    subtitle: 'Công nghệ Sandwich Panel — bền, đẹp, tiết kiệm năng lượng',
  ),
  _HeroBanner(
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2020/01/1920-1080.jpg',
    title: 'ISUZU Thùng Đông Lạnh',
    subtitle: 'Chuyên chở hàng lạnh — thủy sản, dược phẩm, thực phẩm',
  ),
  _HeroBanner(
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/08/HINH-TRANG-CHU-1-1920-X-1080-px-1.png',
    title: 'HINO Thùng Bảo Ôn',
    subtitle: 'Phân phối toàn quốc — xuất khẩu Nhật Bản, Hàn Quốc, Úc',
  ),
];

const _kCategories = [
  _CategoryData(
    name: 'Thùng Tải Lạnh',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/05/F1L.2020-Isuzu-700x700.png',
    desc: 'Thuỷ sản, Rau củ, Kem, Sữa, Dược phẩm...',
    webUrl: 'https://quyenauto.com/products-category/thung-tai-lanh/',
  ),
  _CategoryData(
    name: 'Thùng Bảo Ôn',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2020/12/F1-HINO-432-tach-nen700x700.png',
    desc: 'Giữ nhiệt ổn định trong suốt hành trình',
    webUrl: 'https://quyenauto.com/products-category/thung-bao-on/',
  ),
  _CategoryData(
    name: 'Thùng Tải Kín',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/11/TK-HINO-FG.png',
    desc: 'An toàn, bảo mật hàng hoá mọi địa hình',
    webUrl: 'https://quyenauto.com/products-category/thung-tai-kin/',
  ),
  _CategoryData(
    name: 'Thùng Thiết Kế',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2023/06/Combo-4-xe-thiet-ke-Quyen-Auto.png',
    desc: 'Thiết kế đặc biệt theo yêu cầu khách hàng',
    webUrl: 'https://quyenauto.com/thung-thiet-ke/',
  ),
];

const _kNews = [
  _NewsData(
    title:
        'Quyen Auto đào tạo sản phẩm & huấn luyện bảo dưỡng thùng xe lạnh cho đại lý ISUZU khu vực Miền Bắc',
    date: '04/2026',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2026/04/IMG_7249-edited-scaled.jpg',
    link:
        'https://quyenauto.com/quyen-auto-dao-tao-san-pham-huan-luyen-bao-duong-thung-xe-lanh-cho-dai-ly-isuzu-khu-vuc-mien-bac/',
  ),
  _NewsData(
    title:
        'Chương trình đào tạo sản phẩm cho đại lý ISUZU tại Quyen Auto 2026',
    date: '04/2026',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2026/04/1-scaled.jpg',
    link:
        'https://quyenauto.com/chuong-trinh-dao-tao-san-pham-cho-dai-ly-isuzu-tai-quyen-auto-2026/',
  ),
  _NewsData(
    title: 'Tất niên Quyen Auto 2025',
    date: '02/2026',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2026/02/1-scaled.jpg',
    link: 'https://quyenauto.com/https-quyenauto-com-tat-nien-quyen-auto-2025/',
  ),
  _NewsData(
    title:
        'Thùng lạnh Quyen Auto — sự khác biệt đến từ công nghệ Sandwich Panel',
    date: '05/2026',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2026/05/thung-lanh-cong-nghe-sandwich-panel-thumbnail.webp',
    link: 'https://quyenauto.com/thung-lanh-cong-nghe-sandwich-panel/',
  ),
];

// ─── Model classes ────────────────────────────────────────────────────────────

class _HeroBanner {
  final String imageUrl;
  final String title;
  final String subtitle;
  const _HeroBanner(
      {required this.imageUrl,
      required this.title,
      required this.subtitle});
}

class _CategoryData {
  final String name;
  final String imageUrl;
  final String desc;
  final String webUrl;
  const _CategoryData(
      {required this.name,
      required this.imageUrl,
      required this.desc,
      required this.webUrl});
}

class _NewsData {
  final String title;
  final String date;
  final String imageUrl;
  final String link;
  const _NewsData(
      {required this.title,
      required this.date,
      required this.imageUrl,
      required this.link});
}

// ─── HomeScreen (shell với 5 tab) ────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    final ordersAsync = ref.watch(orderListProvider);
    final processingCount = ordersAsync.valueOrNull
            ?.where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.inProduction)
            .length ??
        0;

    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    void switchTab(int i) {
      if (!isLoggedIn && i >= 2) {
        context.push(AppRoutes.login);
        return;
      }
      ref.read(homeTabIndexProvider.notifier).state = i;
    }

    final tabs = <Widget>[
      HomeTab(onSwitchTab: switchTab),
      const ProductListScreen(),
      const OrderListScreen(),
      const WarrantyScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: switchTab,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 16,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: processingCount > 0,
              badgeContent: Text(
                '$processingCount',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            activeIcon: badges.Badge(
              showBadge: processingCount > 0,
              badgeContent: Text(
                '$processingCount',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              child: const Icon(Icons.receipt_long),
            ),
            label: 'Đơn hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Bảo hành',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

// ─── HomeTab ──────────────────────────────────────────────────────────────────

class HomeTab extends ConsumerStatefulWidget {
  final void Function(int) onSwitchTab;
  const HomeTab({super.key, required this.onSwitchTab});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final _bannerController = PageController();
  Timer? _bannerTimer;
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerTimer =
        Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _bannerIndex = (_bannerIndex + 1) % _kHeroBanners.length;
      _bannerController.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final notifCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            elevation: 0,
            title: SizedBox(
              height: 42,
              child: CachedNetworkImage(
                imageUrl: _kLogoUrl,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                errorWidget: (_, _, _) => const Text(
                  'Quyen Auto',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            actions: [
              badges.Badge(
                showBadge: notifCount > 0,
                position:
                    badges.BadgePosition.topEnd(top: 6, end: 6),
                badgeContent: Text(
                  '$notifCount',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 9),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textWhite),
                  onPressed: () =>
                      context.push(AppRoutes.notifications),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Scrollable body ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner Slider ───────────────────────────────────────
                _HeroBannerSlider(controller: _bannerController),
                const SizedBox(height: 20),

                // ── Dịch vụ nhanh ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Dịch vụ nhanh'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ShortcutCard(
                              icon: Icons.request_quote_outlined,
                              label: 'Báo giá nhanh',
                              color: AppColors.primaryOrange,
                              onTap: () =>
                                  context.push(AppRoutes.quotation),
                            ),
                          ),
                          Expanded(
                            child: ShortcutCard(
                              icon: Icons.receipt_long_outlined,
                              label: 'Đơn hàng',
                              color: AppColors.infoBlue,
                              onTap: () => widget.onSwitchTab(2),
                            ),
                          ),
                          Expanded(
                            child: ShortcutCard(
                              icon: Icons.build_outlined,
                              label: 'Bảo hành',
                              color: AppColors.successGreen,
                              onTap: () => widget.onSwitchTab(3),
                            ),
                          ),
                          Expanded(
                            child: ShortcutCard(
                              icon: Icons.phone_outlined,
                              label: 'Liên hệ',
                              color: AppColors.primaryNavy,
                              onTap: () =>
                                  launchUrlString('tel:0908109929'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Danh mục sản phẩm ───────────────────────────────────────
                _ProductCategoriesSection(),
                const SizedBox(height: 24),

                // ── Sản phẩm nổi bật ────────────────────────────────────────
                _FeaturedProductsSection(
                    productsAsync: productsAsync),
                const SizedBox(height: 24),

                // ── Tin tức nổi bật ─────────────────────────────────────────
                _NewsSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title helper ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle(this.text, {this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.primaryOrange),
            ),
          ),
      ],
    );
  }
}

// ─── Hero Banner Slider ───────────────────────────────────────────────────────

class _HeroBannerSlider extends StatelessWidget {
  final PageController controller;
  const _HeroBannerSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            itemCount: _kHeroBanners.length,
            itemBuilder: (_, i) {
              final banner = _kHeroBanners[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: AppColors.primaryNavy,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryOrange),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.primaryNavy,
                      child: const Icon(Icons.local_shipping,
                          color: Colors.white, size: 60),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  // Text overlay
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54)
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: controller,
          count: _kHeroBanners.length,
          effect: const WormEffect(
            dotHeight: 7,
            dotWidth: 7,
            spacing: 6,
            activeDotColor: AppColors.primaryOrange,
            dotColor: AppColors.borderLight,
          ),
        ),
      ],
    );
  }
}

// ─── Product Categories ───────────────────────────────────────────────────────

class _ProductCategoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            'Danh mục sản phẩm',
            actionLabel: 'Xem tất cả',
            onAction: () => context.go(AppRoutes.catalogue),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: _kCategories.length,
            itemBuilder: (_, i) =>
                _CategoryCard(data: _kCategories[i]),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrlString(data.webUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Product image
            CachedNetworkImage(
              imageUrl: data.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: AppColors.backgroundLight,
                  child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange))),
              errorWidget: (_, _, _) => Container(
                color: AppColors.backgroundLight,
                child: const Icon(Icons.local_shipping_outlined,
                    color: AppColors.primaryNavy, size: 40),
              ),
            ),
            // Bottom gradient + label
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.desc,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Featured Products ────────────────────────────────────────────────────────

class _FeaturedProductsSection extends StatelessWidget {
  final AsyncValue<List<Product>> productsAsync;
  const _FeaturedProductsSection({required this.productsAsync});

  @override
  Widget build(BuildContext context) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle(
                'Sản phẩm nổi bật',
                actionLabel: 'Xem tất cả',
                onAction: () => context.go(AppRoutes.catalogue),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 185,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 12),
                itemBuilder: (_, i) =>
                    _ProductCard(product: products[i]),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.productOf(product.id)),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 105,
              width: double.infinity,
              child: product.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrls.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(Icons.local_shipping_outlined,
                            color: AppColors.primaryNavy, size: 36),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.local_shipping_outlined,
                          color: AppColors.primaryNavy, size: 36),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Liên hệ báo giá',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── News Section ─────────────────────────────────────────────────────────────

class _NewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            'Tin tức nổi bật',
            actionLabel: 'Xem thêm',
            onAction: () =>
                launchUrlString('https://quyenauto.com/tin-tuc/'),
          ),
          const SizedBox(height: 12),
          // Feature card (first news, large)
          _NewsCardLarge(item: _kNews[0]),
          const SizedBox(height: 12),
          // Remaining news — compact list
          ..._kNews.skip(1).map((n) => _NewsCardCompact(item: n)),
        ],
      ),
    );
  }
}

class _NewsCardLarge extends StatelessWidget {
  final _NewsData item;
  const _NewsCardLarge({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrlString(item.link),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: AppColors.backgroundLight),
              errorWidget: (_, _, _) => Container(
                  color: AppColors.backgroundLight,
                  child: const Icon(Icons.article_outlined,
                      size: 40, color: AppColors.textGray)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.date,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCardCompact extends StatelessWidget {
  final _NewsData item;
  const _NewsCardCompact({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrlString(item.link),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 90,
              height: 72,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.backgroundLight),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.backgroundLight,
                  child: const Icon(Icons.article_outlined,
                      color: AppColors.textGray, size: 24),
                ),
              ),
            ),
            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11,
                            color: AppColors.textGray),
                        const SizedBox(width: 4),
                        Text(
                          item.date,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGray),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 11,
                            color: AppColors.primaryOrange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
