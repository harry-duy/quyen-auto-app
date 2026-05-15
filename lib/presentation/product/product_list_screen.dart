import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';

// ─── Categories ──────────────────────────────────────────────────────────────

const _kCategories = [
  (value: null,          label: 'Tất cả'),
  (value: 'REFRIGERATED', label: 'Tải lạnh'),
  (value: 'INSULATED',    label: 'Bảo ôn'),
  (value: 'ENCLOSED',    label: 'Tải kín'),
  (value: 'CUSTOM',      label: 'Thiết kế'),
];

// Static category showcase data using real images from quyenauto.com
const _kCategoryShowcase = [
  _CategoryData(
    value: 'REFRIGERATED',
    label: 'Thùng Tải Lạnh',
    description: 'Giữ lạnh hoàn hảo',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/05/F1L.2020-Isuzu-700x700.png',
    color: Color(0xFF0D47A1),
  ),
  _CategoryData(
    value: 'INSULATED',
    label: 'Thùng Bảo Ôn',
    description: 'Cách nhiệt tối ưu',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2020/12/F1-HINO-432-tach-nen700x700.png',
    color: Color(0xFF1B5E20),
  ),
  _CategoryData(
    value: 'ENCLOSED',
    label: 'Thùng Tải Kín',
    description: 'Chắc chắn, an toàn',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/11/TK-HINO-FG.png',
    color: Color(0xFF4A148C),
  ),
  _CategoryData(
    value: 'CUSTOM',
    label: 'Thiết Kế Riêng',
    description: 'Theo yêu cầu khách',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2023/06/Combo-4-xe-thiet-ke-Quyen-Auto.png',
    color: Color(0xFFBF360C),
  ),
];

class _CategoryData {
  final String value;
  final String label;
  final String description;
  final String imageUrl;
  final Color color;
  const _CategoryData({
    required this.value,
    required this.label,
    required this.description,
    required this.imageUrl,
    required this.color,
  });
}

// ─── Featured models (static, from quyenauto.com) ────────────────────────────

class _ModelData {
  final String name;
  final String categoryLabel;
  final String categoryValue;
  final String chassis;
  final String imageUrl;
  final Color color;
  const _ModelData({
    required this.name,
    required this.categoryLabel,
    required this.categoryValue,
    required this.chassis,
    required this.imageUrl,
    required this.color,
  });
}

const _kFeaturedModels = [
  _ModelData(
    name: 'Tải Lạnh Trên 6T',
    categoryLabel: 'Tải Lạnh',
    categoryValue: 'REFRIGERATED',
    chassis: 'ISUZU · HINO · HYUNDAI',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/08/F1-ISUZU-tach-nen700x700.png',
    color: Color(0xFF0D47A1),
  ),
  _ModelData(
    name: 'Tải Lạnh Dưới 6T',
    categoryLabel: 'Tải Lạnh',
    categoryValue: 'REFRIGERATED',
    chassis: 'ISUZU · HINO · FUSO',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/03/F1S-new-tach-nen700x700.png',
    color: Color(0xFF0D47A1),
  ),
  _ModelData(
    name: 'Bảo Ôn Trên 6T',
    categoryLabel: 'Bảo Ôn',
    categoryValue: 'INSULATED',
    chassis: 'HINO · ISUZU · HYUNDAI',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/01/HINO-BO-TREN-6-TAN-1.png',
    color: Color(0xFF1B5E20),
  ),
  _ModelData(
    name: 'Bảo Ôn Dưới 6T',
    categoryLabel: 'Bảo Ôn',
    categoryValue: 'INSULATED',
    chassis: 'ISUZU · HINO · HYUNDAI',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2022/11/BAO-ON-DUOI-6-TAN-VIEW-1.png',
    color: Color(0xFF1B5E20),
  ),
  _ModelData(
    name: 'Tải Kín Trên 6T',
    categoryLabel: 'Tải Kín',
    categoryValue: 'ENCLOSED',
    chassis: 'HINO · ISUZU · HYUNDAI',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/11/TK-HINO-FG.png',
    color: Color(0xFF4A148C),
  ),
  _ModelData(
    name: 'Tải Kín Dưới 6T',
    categoryLabel: 'Tải Kín',
    categoryValue: 'ENCLOSED',
    chassis: 'HINO · ISUZU · KIA',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/08/TK-HINO-XZU-65.png',
    color: Color(0xFF4A148C),
  ),
  _ModelData(
    name: 'PICKUP Đông Lạnh',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'Isuzu D-MAX',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2025/01/Dmax-Quyen-Auto-700x700-front.png',
    color: Color(0xFFBF360C),
  ),
  _ModelData(
    name: 'VAN Đông Lạnh',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'THACO VAN',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/11/Thaco-van-front-back-tach-nen-700x700-logo.png',
    color: Color(0xFFBF360C),
  ),
  _ModelData(
    name: 'Xe Chở Gà Con\nTrên 8T',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'HINO',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2021/01/Xe-ga-HINO-2-xe-tach-nen-700x700.png',
    color: Color(0xFFBF360C),
  ),
  _ModelData(
    name: 'Xe Bán Hàng\nLưu Động',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'ISUZU · HINO',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/12/Thung-xe-ban-hang-tach-nen-700x700.png',
    color: Color(0xFFBF360C),
  ),
  _ModelData(
    name: 'Thùng Xe\nCánh Dơi',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'ISUZU · HINO',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2018/12/Thung-xe-canh-doi-tach-nen-700x700.png',
    color: Color(0xFFBF360C),
  ),
  _ModelData(
    name: 'Sơ-mi Rơ Mooc\nĐông Lạnh',
    categoryLabel: 'Thiết Kế',
    categoryValue: 'CUSTOM',
    chassis: 'Semi-Trailer',
    imageUrl:
        'https://quyenauto.com/wp-content/uploads/2019/10/SEMI-TRAILER-DL.png',
    color: Color(0xFFBF360C),
  ),
];

// ─── Providers ───────────────────────────────────────────────────────────────

final _searchQueryProvider = StateProvider<String>((ref) => '');
final _pageIndexProvider   = StateProvider<int>((ref) => 0);

final _allProductsProvider =
    StateNotifierProvider<_ProductListNotifier, AsyncValue<List<Product>>>(
        (ref) => _ProductListNotifier(ref));

class _ProductListNotifier
    extends StateNotifier<AsyncValue<List<Product>>> {
  final Ref _ref;
  bool _hasMore = true;

  _ProductListNotifier(this._ref) : super(const AsyncLoading()) {
    _load(reset: true);
    _ref.listen(productCategoryProvider, (_, __) => _load(reset: true));
    _ref.listen(_searchQueryProvider, (_, __) => _load(reset: true));
  }

  bool get hasMore => _hasMore;

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _ref.read(_pageIndexProvider.notifier).state = 0;
      state = const AsyncLoading();
    }
    final page     = _ref.read(_pageIndexProvider);
    final category = _ref.read(productCategoryProvider);
    final search   = _ref.read(_searchQueryProvider);
    try {
      final repo    = _ref.read(productRepositoryProvider);
      final results = await repo.getProducts(
        page: page,
        size: 10,
        category: category,
        search: search.isEmpty ? null : search,
      );
      _hasMore = results.length >= 10;
      if (reset || page == 0) {
        state = AsyncData(results);
      } else {
        final current = state.valueOrNull ?? [];
        state = AsyncData([...current, ...results]);
      }
    } catch (e, st) {
      if (reset || page == 0) state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _ref.read(_pageIndexProvider.notifier).state++;
    await _load();
  }

  Future<void> refresh() async => _load(reset: true);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController  = ScrollController();
  final _searchController  = TextEditingController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(_allProductsProvider.notifier).loadMore();
    }
  }

  void _selectCategory(String? value) {
    ref.read(productCategoryProvider.notifier).state = value;
  }

  @override
  Widget build(BuildContext context) {
    final selected      = ref.watch(productCategoryProvider);
    final productsAsync = ref.watch(_allProductsProvider);
    final isSearching   = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: AppColors.textWhite,
            title: const Text(
              'Catalogue',
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            expandedHeight: 116,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryNavy,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SafeArea(
                  top: false,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      ref.read(_searchQueryProvider.notifier).state = v.trim();
                      setState(() {}); // rebuild to show/hide banner
                    },
                    style: const TextStyle(color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: AppColors.textGray),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textGray),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(_searchQueryProvider.notifier)
                                    .state = '';
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Hero banner ─────────────────────────────────────────────────────
          if (!isSearching)
            const SliverToBoxAdapter(child: _HeroBanner()),

          // ── Category showcase ────────────────────────────────────────────────
          if (!isSearching)
            SliverToBoxAdapter(
              child: _CategoryShowcase(
                selected: selected,
                onSelect: _selectCategory,
              ),
            ),

          // ── Featured models ──────────────────────────────────────────────────
          if (!isSearching)
            SliverToBoxAdapter(
              child: _FeaturedModelsSection(
                selectedCategory: selected,
                onSelectCategory: _selectCategory,
              ),
            ),

          // ── Filter chips ─────────────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterChipsDelegate(
              selected: selected,
              onSelect: _selectCategory,
            ),
          ),

          // ── Product grid ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64,
                              color:
                                  AppColors.textGray.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Không có sản phẩm',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.textGray),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => _selectCategory(null),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final totalCount = products.length +
                    (ref.read(_allProductsProvider.notifier).hasMore ? 1 : 0);

                return SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i >= products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return ProductCard(product: products[i]);
                    },
                    childCount: totalCount,
                  ),
                );
              },
              loading: () => SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => _ShimmerCard(),
                  childCount: 4,
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.errorRed, size: 56),
                        const SizedBox(height: 14),
                        const Text('Không thể tải sản phẩm',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.textGray)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref
                              .read(_allProductsProvider.notifier)
                              .refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
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

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primaryNavy,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://quyenauto.com/wp-content/uploads/2026/04/FSR-Quyen-Auto-1-scaled.jpg',
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primaryNavy.withValues(alpha: 0.85),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'QUYEN AUTO',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Xe thùng\nchất lượng cao',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ISO 9001:2015 • 40+ năm',
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
    );
  }
}

// ─── Category Showcase ───────────────────────────────────────────────────────

class _CategoryShowcase extends StatelessWidget {
  final String? selected;
  final void Function(String?) onSelect;
  const _CategoryShowcase({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Dòng sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _kCategoryShowcase.length,
          itemBuilder: (_, i) {
            final cat = _kCategoryShowcase[i];
            final isSelected = selected == cat.value;
            return _CategoryCard(
              data: cat,
              isSelected: isSelected,
              onTap: () => onSelect(isSelected ? null : cat.value),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: data.color,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Product image
            CachedNetworkImage(
              imageUrl: data.imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
            // Left-side gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    data.color.withValues(alpha: 0.95),
                    data.color.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            // Text
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: TextStyle(
                      color: AppColors.textWhite.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textWhite
                          : AppColors.textWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isSelected ? '✓ Đang lọc' : 'Xem ngay →',
                      style: TextStyle(
                        color: isSelected ? data.color : AppColors.textWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

// ─── Featured Models Section ──────────────────────────────────────────────────

class _FeaturedModelsSection extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String?) onSelectCategory;
  const _FeaturedModelsSection({
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final models = selectedCategory == null
        ? _kFeaturedModels
        : _kFeaturedModels
            .where((m) => m.categoryValue == selectedCategory)
            .toList();

    if (models.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Xe tiêu biểu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${models.length} mẫu',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: models.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ModelCard(
              model: models[i],
              onTap: () => onSelectCategory(models[i].categoryValue),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final _ModelData model;
  final VoidCallback onTap;
  const _ModelCard({required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 115,
              color: model.color.withValues(alpha: 0.06),
              child: CachedNetworkImage(
                imageUrl: model.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.local_shipping_outlined,
                      size: 40, color: model.color.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: model.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      model.categoryLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: model.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model.chassis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.quotation),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Báo giá',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Persistent filter chips header ─────────────────────────────────────────

class _FilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final String? selected;
  final void Function(String?) onSelect;
  const _FilterChipsDelegate({required this.selected, required this.onSelect});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(_FilterChipsDelegate old) =>
      old.selected != selected;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: _kCategories.map((cat) {
            final isActive = selected == cat.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.label),
                selected: isActive,
                onSelected: (_) => onSelect(cat.value),
                selectedColor: AppColors.primaryNavy,
                checkmarkColor: AppColors.textWhite,
                labelStyle: TextStyle(
                  color: isActive ? AppColors.textWhite : AppColors.textDark,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
                backgroundColor: AppColors.backgroundLight,
                side: BorderSide(
                  color: isActive
                      ? AppColors.primaryNavy
                      : AppColors.borderLight,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Shimmer placeholder ─────────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
