import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quyen_auto_app/data/repositories/order_repository_impl.dart';
import 'package:quyen_auto_app/data/services/api_service.dart';
import 'package:quyen_auto_app/domain/entities/order.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late OrderRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiService();
    repo = OrderRepositoryImpl(mockApi);
  });

  group('getOrderById', () {
    test('maps OrderResponse to Order entity correctly', () async {
      when(() => mockApi.get<Order>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((inv) async {
        final fromData =
            inv.namedArguments[const Symbol('fromData')] as Order Function(dynamic);
        final order = fromData({
          'id': 42,
          'quotationId': 10,
          'totalAmount': 350000000.0,
          'depositAmount': 50000000.0,
          'status': 'confirmed',
          'productionStatus': 'WAITING',
          'orderCode': '#ORD-42',
          'productName': 'Xe thùng lạnh 5T',
          'note': 'Giao gấp',
          'createdAt': '2025-05-01T10:30:00.000Z',
          'estimatedDate': '2025-06-01T10:30:00.000Z',
          'statusLogs': [],
        });

        return ServiceResult(
          success: true,
          message: 'OK',
          statusCode: 200,
          data: order,
        );
      });

      final order = await repo.getOrderById('42');

      expect(order.id, '42');
      expect(order.orderCode, '#ORD-42');
      expect(order.productName, 'Xe thùng lạnh 5T');
      expect(order.status, OrderStatus.confirmed);
      expect(order.totalAmount, 350000000.0);
      expect(order.note, 'Giao gấp');
    });

    test('uses fallback orderCode when null', () async {
      when(() => mockApi.get<Order>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((inv) async {
        final fromData =
            inv.namedArguments[const Symbol('fromData')] as Order Function(dynamic);
        final order = fromData({
          'id': 99,
          'quotationId': 1,
          'totalAmount': 0.0,
          'depositAmount': 0.0,
          'status': 'pending',
          'productionStatus': 'NONE',
          'statusLogs': [],
        });

        return ServiceResult(
          success: true,
          message: 'OK',
          statusCode: 200,
          data: order,
        );
      });

      final order = await repo.getOrderById('99');

      expect(order.orderCode, '#ORD-99');
      expect(order.productName, 'Đơn hàng #99');
      expect(order.status, OrderStatus.pending);
    });

    test('parses inProduction status with underscore', () async {
      when(() => mockApi.get<Order>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((inv) async {
        final fromData =
            inv.namedArguments[const Symbol('fromData')] as Order Function(dynamic);
        final order = fromData({
          'id': 5,
          'quotationId': 1,
          'totalAmount': 100000.0,
          'depositAmount': 10000.0,
          'status': 'in_production',
          'productionStatus': 'WELDING',
          'statusLogs': [],
        });

        return ServiceResult(
          success: true,
          message: 'OK',
          statusCode: 200,
          data: order,
        );
      });

      final order = await repo.getOrderById('5');
      expect(order.status, OrderStatus.inProduction);
    });
  });

  group('getOrders', () {
    test('returns empty list on null data', () async {
      when(() => mockApi.get<List<Order>>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((_) async => const ServiceResult(
            success: true,
            message: 'OK',
            statusCode: 200,
            data: null,
          ));

      final orders = await repo.getOrders();
      expect(orders, isEmpty);
    });
  });
}
