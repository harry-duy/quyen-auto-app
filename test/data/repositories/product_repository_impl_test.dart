import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quyen_auto_app/data/repositories/product_repository_impl.dart';
import 'package:quyen_auto_app/data/services/api_service.dart';
import 'package:quyen_auto_app/domain/entities/product.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService mockApi;
  late ProductRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiService();
    repo = ProductRepositoryImpl(mockApi);
  });

  group('getProductById', () {
    test('maps ProductResponse to Product entity correctly', () async {
      when(() => mockApi.get<Product>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((inv) async {
        final fromData =
            inv.namedArguments[const Symbol('fromData')] as Product Function(dynamic);
        final product = fromData({
          'id': 10,
          'name': 'Xe thùng lạnh 5 tấn',
          'category': 'REFRIGERATED',
          'weightCapacity': '5 tấn',
          'description': 'Xe thùng lạnh chất lượng cao',
          'priceRangeMin': 350000000.0,
          'priceRangeMax': 450000000.0,
          'images': [
            {'id': 1, 'url': 'https://example.com/img1.jpg', 'isPrimary': true},
            {'id': 2, 'url': 'https://example.com/img2.jpg', 'isPrimary': false},
          ],
          'isActive': true,
        });

        return ServiceResult(
          success: true,
          message: 'OK',
          statusCode: 200,
          data: product,
        );
      });

      final product = await repo.getProductById('10');

      expect(product.id, '10');
      expect(product.name, 'Xe thùng lạnh 5 tấn');
      expect(product.category, 'REFRIGERATED');
      expect(product.truckType, '5 tấn');
      expect(product.price, 350000000.0);
      expect(product.imageUrls.length, 2);
      expect(product.inStock, true);
    });

    test('maps product with empty images', () async {
      when(() => mockApi.get<Product>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((inv) async {
        final fromData =
            inv.namedArguments[const Symbol('fromData')] as Product Function(dynamic);
        final product = fromData({
          'id': 20,
          'name': 'Xe bảo ôn',
          'category': 'INSULATED',
          'weightCapacity': '3 tấn',
          'description': '',
          'priceRangeMin': 0.0,
          'priceRangeMax': 0.0,
          'images': <dynamic>[],
          'isActive': false,
        });

        return ServiceResult(
          success: true,
          message: 'OK',
          statusCode: 200,
          data: product,
        );
      });

      final product = await repo.getProductById('20');

      expect(product.imageUrls, isEmpty);
      expect(product.price, 0.0);
      expect(product.inStock, false);
    });
  });
}
