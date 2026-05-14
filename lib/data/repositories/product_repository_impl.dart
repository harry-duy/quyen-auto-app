import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/response/product_response.dart';
import '../services/api_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiService _api;

  ProductRepositoryImpl(this._api);

  Box<String> get _cacheBox => Hive.box<String>('cache');

  /// Handles both plain-list and paginated `{"content":[...],"page":0,...}` responses.
  List<dynamic> _items(dynamic json) {
    if (json is Map<String, dynamic> && json['content'] is List) {
      return json['content'] as List;
    }
    return json as List;
  }

  Product _fromResponse(ProductResponse r) => Product(
        id: r.id.toString(),
        name: r.name,
        description: r.description,
        price: r.basePrice,
        category: r.categoryName ?? '',
        imageUrls: r.imageUrls,
        truckType: null, // weightCapacity stored in specifications JSON
        inStock: r.isActive,
      );

  Future<bool> _hasNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  String _listCacheKey(int page, String? category, String? search) {
    return 'products_p${page}_c${category ?? 'all'}_s${search ?? ''}';
  }

  @override
  Future<List<Product>> getProducts({
    int page = 0,
    int size = 10,
    String? category,
    String? search,
  }) async {
    final cacheKey = _listCacheKey(page, category, search);

    if (await _hasNetwork()) {
      final res = await _api.get<List<Product>>(
        ApiConstants.productList,
        queryParams: {
          'page': page,
          'size': size,
          if (category != null) 'category': category,
          if (search != null) 'search': search,
        },
        fromData: (json) => _items(json)
            .map((e) => _fromResponse(
                ProductResponse.fromJson(e as Map<String, dynamic>)))
            .toList(),
      );

      final products = res.data ?? [];

      // Cache the raw JSON for offline use
      try {
        final rawList = products
            .map((p) => {
                  'id': p.id,
                  'name': p.name,
                  'description': p.description,
                  'price': p.price,
                  'category': p.category,
                  'imageUrls': p.imageUrls,
                  'truckType': p.truckType,
                  'inStock': p.inStock,
                })
            .toList();
        await _cacheBox.put(cacheKey, jsonEncode(rawList));
      } catch (_) {}

      return products;
    }

    // Offline: return cached data
    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((e) => Product(
                id: e['id'] as String,
                name: e['name'] as String,
                description: e['description'] as String,
                price: (e['price'] as num).toDouble(),
                category: e['category'] as String,
                imageUrls: List<String>.from(e['imageUrls'] as List),
                truckType: e['truckType'] as String?,
                inStock: e['inStock'] as bool,
              ))
          .toList();
    }

    return [];
  }

  @override
  Future<Product> getProductById(String id) async {
    final res = await _api.get<Product>(
      ApiConstants.resolve(ApiConstants.productDetail, {'id': id}),
      fromData: (json) =>
          _fromResponse(ProductResponse.fromJson(json as Map<String, dynamic>)),
    );
    return res.data!;
  }
}
