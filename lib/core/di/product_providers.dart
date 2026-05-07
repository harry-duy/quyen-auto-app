import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import 'service_providers.dart';

// ─── Product Providers ───────────────────────────────────────────────────────

final productCategoryProvider = StateProvider<String?>((ref) => null);

final productListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final category = ref.watch(productCategoryProvider);
  return repo.getProducts(page: 0, size: 20, category: category);
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  return ref.watch(productRepositoryProvider).getProductById(id);
});
