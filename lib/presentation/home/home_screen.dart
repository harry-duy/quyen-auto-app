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
import '../../core/utils/product_image_helper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../order/order_list_screen.dart';
import '../product/product_list_screen.dart';
import '../profile/profile_screen.dart';
import '../warranty/warranty_screen.dart';
import '../widgets/shortcut_card.dart';

// ─── HomeScreen (shell với 5 tab) ────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex  = ref.watch(homeTabIndexProvider);
    final isLoggedIn    = ref.watch(isAuthenticatedProvider);
    final ordersAsync   = isLoggedIn ? ref.watch(orderListProvider) : null;
    final processingCount = ordersAsync?.valueOrNull
            ?.where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.inProduction)
            .length ??
        0;

    void switchTab(int i) {
      if (!isLoggedIn && i >= 2) {
        context.push(AppRoutes.login);
        return;
      }
      ref.read(homeTabIndexProvider.notifier).state = i;
    }

    final guestTabs = <Widget>[
      HomeTab(onSwitchTab: switchTab),
      const ProductListScreen(),
    ];

    final fullTabs = <Widget>[
      HomeTab(onSwitchTab: switchTab),
      const ProductListScreen(),
      const OrderListScreen(),
      const WarrantyScreen(),
      const ProfileScreen(),
    ];

    final tabs = isLoggedIn ? fullTabs : guestTabs;
    final safeIndex = currentIndex < tabs.length ? currentIndex : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
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
          if (isLoggedIn) ...[
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
          ] else
            BottomNavigationBarItem(
              icon: const Icon(Icons.login_outlined),
              activeIcon: const Icon(Icons.login),
              label: 'Đăng nhập',
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

  // Real news from quyenauto.com
  static const _news = [
    _NewsData(
      title: 'Ra mắt ISUZU FSR-N & Giải pháp vận tải thủy hải sản tại Thanh Hóa',
      subtitle: 'Dòng thùng bảo ôn OXY Quyen Auto dành riêng cho ngành thủy sản',
      date: '19/04/2026',
      imageUrl: 'https://quyenauto.com/wp-content/uploads/2026/04/FSR-Quyen-Auto-1-scaled.jpg',
      icon: Icons.local_shipping_outlined,
    ),
    _NewsData(
      title: 'Quyen Auto đào tạo bảo dưỡng thùng lạnh cho đại lý ISUZU miền Bắc',
      subtitle: 'Chương trình đào tạo sản phẩm & kỹ thuật bảo dưỡng thùng xe lạnh',
      date: '04/04/2026',
      imageUrl: 'https://quyenauto.com/wp-content/uploads/2026/04/IMG_7249-edited-scaled.jpg',
      icon: Icons.build_outlined,
    ),
    _NewsData(
      title: 'Chương trình đào tạo sản phẩm cho đại lý ISUZU tại Quyen Auto 2026',
      subtitle: 'Nâng cao kiến thức chuyên môn cho hệ thống đại lý trên toàn quốc',
      date: '02/04/2026',
      imageUrl: 'https://quyenauto.com/wp-content/uploads/2026/04/1-scaled.jpg',
      icon: Icons.school_outlined,
    ),
    _NewsData(
      title: 'Tất niên Quyen Auto 2025 — Cùng nhìn lại một năm thành công',
      subtitle: 'Lễ tất niên ấm áp, ghi dấu những thành tựu nổi bật của năm 2025',
      date: '05/02/2026',
      imageUrl: 'https://quyenauto.com/wp-content/uploads/2026/02/1-scaled.jpg',
      icon: Icons.celebration_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start auto-play after the first frame so PageController is attached
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoPlay());
  }

  void _startAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final products = ref.read(productListProvider).valueOrNull;
      final count = (products?.take(5).length ?? 0);
      if (count < 2) return;
      final current = _bannerController.page?.round() ?? 0;
      final next = (current + 1) >= count ? 0 : current + 1;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
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
            title: Image.asset(
              'assets/images/LOGO QA-white-red.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            actions: [
              badges.Badge(
                showBadge: notifCount > 0,
                position: badges.BadgePosition.topEnd(top: 6, end: 6),
                badgeContent: Text(
                  '$notifCount',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.textWhite),
                  onPressed: () => context.push(AppRoutes.notifications),
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
                const SizedBox(height: 16),

                // Banner PageView + indicator
                _BannerSection(
                  controller: _bannerController,
                  productsAsync: productsAsync,
                ),
                const SizedBox(height: 24),

                // 2×2 ShortcutCard grid (4 cards in one row with GridView)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dịch vụ nhanh',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ShortcutCard(
                              icon: Icons.request_quote_outlined,
                              label: 'Báo giá nhanh',
                              color: AppColors.primaryOrange,
                              onTap: () => context.push(AppRoutes.quotation),
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

                // Featured products horizontal list
                _FeaturedProductsSection(
                  productsAsync: productsAsync,
                  onViewAll: () => widget.onSwitchTab(1),
                ),
                const SizedBox(height: 24),

                // News & promotions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tin tức & Khuyến mãi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._news.map((n) => _NewsCard(item: n)),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  final PageController controller;
  final AsyncValue<List<Product>> productsAsync;

  const _BannerSection({
    required this.controller,
    required this.productsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final products =
        productsAsync.valueOrNull?.take(5).toList() ?? [];

    if (products.isEmpty) {
      return _DefaultBanner();
    }

    return Column(children: [
      SizedBox(
        height: 190,
        child: PageView.builder(
          controller: controller,
          itemCount: products.length,
          itemBuilder: (_, i) => _BannerCard(product: products[i]),
        ),
      ),
      const SizedBox(height: 10),
      SmoothPageIndicator(
        controller: controller,
        count: products.length,
        effect: const WormEffect(
          dotHeight: 7,
          dotWidth: 7,
          spacing: 6,
          activeDotColor: AppColors.primaryOrange,
          dotColor: AppColors.borderLight,
        ),
      ),
    ]);
  }
}

class _DefaultBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF2A3F6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, color: AppColors.textWhite, size: 52),
            SizedBox(height: 10),
            Text(
              'Quyen Auto',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Xe thùng chất lượng cao',
              style: TextStyle(color: AppColors.textWhite, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Product product;
  const _BannerCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.productOf(product.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ProductImageHelper.resolve(product),
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.local_shipping,
                    color: AppColors.textWhite, size: 60),
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
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            // Product info
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Featured Products ────────────────────────────────────────────────────────

class _FeaturedProductsSection extends StatelessWidget {
  final AsyncValue<List<Product>> productsAsync;
  final VoidCallback onViewAll;
  const _FeaturedProductsSection({
    required this.productsAsync,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Expanded(
              child: Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 185,
          child: productsAsync.when(
            data: (products) => products.isEmpty
                ? const Center(
                    child: Text('Không có sản phẩm',
                        style: TextStyle(color: AppColors.textGray)),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ProductCard(product: products[i]),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Icon(Icons.error_outline, color: AppColors.errorRed),
            ),
          ),
        ),
      ],
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
            // Thumbnail
            Container(
              height: 105,
              width: double.infinity,
              color: AppColors.primaryNavy.withValues(alpha: 0.04),
              child: CachedNetworkImage(
                imageUrl: ProductImageHelper.resolve(product),
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.local_shipping_outlined,
                      color: AppColors.primaryNavy, size: 36),
                ),
              ),
            ),
            // Info
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
                  const Row(
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios,
                          size: 9, color: AppColors.primaryOrange),
                    ],
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

// ─── News ─────────────────────────────────────────────────────────────────────

class _NewsData {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final String? imageUrl;

  const _NewsData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    this.imageUrl,
  });
}

class _NewsCard extends StatelessWidget {
  final _NewsData item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          SizedBox(
            width: 90,
            height: 80,
            child: item.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _iconFallback(),
                  )
                : _iconFallback(),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
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

  Widget _iconFallback() => Container(
        color: AppColors.primaryOrange.withValues(alpha: 0.08),
        child: Center(
          child: Icon(item.icon, color: AppColors.primaryOrange, size: 28),
        ),
      );
}
