import 'package:flutter_test/flutter_test.dart';
import 'package:quyen_auto_app/data/services/api_service.dart';

void main() {
  group('ServiceResult.fromJson', () {
    test('parses success response', () {
      final json = {
        'success': true,
        'message': 'OK',
        'statusCode': 200,
        'data': {'id': 1, 'name': 'Test'},
      };

      final result = ServiceResult<Map<String, dynamic>>.fromJson(
        json,
        (d) => d as Map<String, dynamic>,
      );

      expect(result.success, true);
      expect(result.message, 'OK');
      expect(result.statusCode, 200);
      expect(result.data?['id'], 1);
      expect(result.data?['name'], 'Test');
    });

    test('parses response with null data', () {
      final json = {
        'success': true,
        'message': 'No content',
        'statusCode': 204,
      };

      final result = ServiceResult<String>.fromJson(json, (d) => d as String);

      expect(result.success, true);
      expect(result.data, isNull);
    });

    test('parses error response', () {
      final json = {
        'success': false,
        'message': 'Unauthorized',
        'statusCode': 401,
      };

      final result = ServiceResult<String>.fromJson(json, null);

      expect(result.success, false);
      expect(result.message, 'Unauthorized');
      expect(result.statusCode, 401);
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final result = ServiceResult<String>.fromJson(json, null);

      expect(result.success, false);
      expect(result.message, '');
      expect(result.statusCode, 0);
      expect(result.data, isNull);
    });

    test('parses list data', () {
      final json = {
        'success': true,
        'message': 'OK',
        'statusCode': 200,
        'data': [
          {'id': 1},
          {'id': 2},
        ],
      };

      final result = ServiceResult<List<Map<String, dynamic>>>.fromJson(
        json,
        (d) => (d as List).cast<Map<String, dynamic>>(),
      );

      expect(result.data?.length, 2);
    });
  });

  group('ApiException', () {
    test('toString returns message', () {
      const e = ApiException('Connection failed', statusCode: 500);
      expect(e.toString(), 'Connection failed');
      expect(e.statusCode, 500);
    });
  });
}
