import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';

// ─── Categories ──────────────────────────────────────────────────────────────

const _kCategories = [
  (value: null, label: 'Tất cả'),
  (value: 'REFRIGERATED', label: 'Tải lạnh'),
  (value: 'INSULATED', label: 'Bảo ôn'),
  (value: 'ENCLOSED', label: 'Tải kín'),
  (value: 'CUSTOM', label: 'Thiết kế'),
];

// ─── Providers ───────────────────────────────────────────────────────────────

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _pageIndexProvider = StateProvider<int>((ref) => 0);

final _allProductsProvider = StateNotifierProvider<_ProductListNotifier, AsyncValue<List<Product>>>((ref) {
  return _ProductListNotifier(ref);
});

class _ProductListNotifier extends StateNotifier<AsyncValue<List<Product>>> {
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

    final page = _ref.read(_pageIndexProvider);
    final category = _ref.read(productCategoryProvider);
    final search = _ref.read(_searchQueryProvider);

    try {
      final repo = _ref.read(productRepositoryProvider);
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
      if (reset || page == 0) {
        state = AsyncError(e, st);
      }
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
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(productCategoryProvider);
    final productsAsync = ref.watch(_allProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Catalogue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(_searchQueryProvider.notifier).state = v.trim(),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: const TextStyle(
                    fontSize: 14, color: AppColors.textGray),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textGray),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_searchQueryProvider.notifier).state = '';
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
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _kCategories.map((cat) {
                  final isActive = selected == cat.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.label),
                      selected: isActive,
                      onSelected: (_) => ref
                          .read(productCategoryProvider.notifier)
                          .state = cat.value,
                      selectedColor: AppColors.primaryOrange,
                      checkmarkColor: AppColors.textWhite,
                      labelStyle: TextStyle(
                        color: isActive
                            ? AppColors.textWhite
                            : AppColors.textDark,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      backgroundColor: AppColors.backgroundLight,
                      side: BorderSide(
                        color: isActive
                            ? AppColors.primaryOrange
                            : AppColors.borderLight,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Product grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: AppColors.textGray.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        const Text('Không có sản phẩm',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.textGray)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(_allProductsProvider.notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length +
                        (ref.read(_allProductsProvider.notifier).hasMore
                            ? 1
                            : 0),
                    itemBuilder: (_, i) {
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
                  ),
                );
              },
              loading: () => const _ShimmerGrid(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 56),
                      const SizedBox(height: 14),
                      const Text(
                        'Không thể tải sản phẩm',
                        style: TextStyle(
                            fontSize: 15, color: AppColors.textGray),
                      ),
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
        ],
      ),
    );
  }
}

// ─── Shimmer placeholder ─────────────────────────────────────────────────────

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.surface,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
