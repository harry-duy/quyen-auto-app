import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    int page = 0,
    int size = 10,
    String? category,
    String? search,
  });

  Future<Product> getProductById(String id);
}
