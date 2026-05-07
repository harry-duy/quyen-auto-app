import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quyen_auto_app/data/repositories/auth_repository_impl.dart';
import 'package:quyen_auto_app/data/services/api_service.dart';
import 'package:quyen_auto_app/data/services/token_service.dart';
import 'package:quyen_auto_app/domain/entities/user.dart';

class MockApiService extends Mock implements ApiService {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockApiService mockApi;
  late MockTokenService mockToken;
  late AuthRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiService();
    mockToken = MockTokenService();
    repo = AuthRepositoryImpl(mockApi, mockToken);

    when(() => mockToken.saveUserRole(any())).thenAnswer((_) async {});
  });

  group('login', () {
    final loginResponseData = {
      'id': '1',
      'fullName': 'Nguyen Van A',
      'phone': '0912345678',
      'email': 'test@test.com',
      'role': 'CUSTOMER',
      'accessToken': 'access_123',
      'refreshToken': 'refresh_456',
    };

    test('returns User and saves tokens on success', () async {
      when(() => mockApi.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((_) async => ServiceResult(
            success: true,
            message: 'OK',
            statusCode: 200,
            data: loginResponseData,
          ));

      when(() => mockToken.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      final user = await repo.login(phone: '0912345678', password: '123456');

      expect(user, isA<User>());
      expect(user.fullName, 'Nguyen Van A');
      expect(user.phone, '0912345678');
      expect(user.role, UserRole.customer);

      verify(() => mockToken.saveTokens(
            accessToken: 'access_123',
            refreshToken: 'refresh_456',
          )).called(1);
    });

    test('maps user with null optional fields', () async {
      when(() => mockApi.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((_) async => ServiceResult(
            success: true,
            message: 'OK',
            statusCode: 200,
            data: {
              'id': 2,
              'fullName': 'User B',
              'phone': '0912345679',
              'role': 'ADMIN',
              'accessToken': 'access_abc',
              'refreshToken': 'refresh_def',
            },
          ));

      when(() => mockToken.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      final user = await repo.login(phone: '0912345679', password: 'pass');

      expect(user.id, '2');
      expect(user.role, UserRole.admin);
      expect(user.email, isNull);
      expect(user.avatarUrl, isNull);
    });
  });

  group('register', () {
    test('returns User on success', () async {
      when(() => mockApi.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((_) async => ServiceResult(
            success: true,
            message: 'OK',
            statusCode: 200,
            data: {
              'id': '3',
              'fullName': 'New User',
              'phone': '0712345678',
              'role': 'CUSTOMER',
              'accessToken': 'tok1',
              'refreshToken': 'tok2',
            },
          ));

      when(() => mockToken.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      final user = await repo.register(
        fullName: 'New User',
        phone: '0712345678',
        password: '123456',
      );

      expect(user.fullName, 'New User');
      expect(user.role, UserRole.customer);
    });
  });

  group('getProfile', () {
    test('returns User from profile endpoint', () async {
      when(() => mockApi.get<Map<String, dynamic>>(
            any(),
            queryParams: any(named: 'queryParams'),
            fromData: any(named: 'fromData'),
          )).thenAnswer((_) async => ServiceResult(
            success: true,
            message: 'OK',
            statusCode: 200,
            data: {
              'id': '1',
              'fullName': 'Profile User',
              'phone': '0912345678',
              'email': 'profile@test.com',
              'avatarUrl': 'https://example.com/avatar.jpg',
              'role': 'CUSTOMER',
            },
          ));

      final user = await repo.getProfile();

      expect(user.fullName, 'Profile User');
      expect(user.email, 'profile@test.com');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.role, UserRole.customer);
    });
  });

  group('logout', () {
    test('clears all tokens', () async {
      when(() => mockToken.clearAllTokens()).thenAnswer((_) async {});

      await repo.logout();

      verify(() => mockToken.clearAllTokens()).called(1);
    });
  });

  group('isLoggedIn', () {
    test('delegates to token service', () async {
      when(() => mockToken.isLoggedIn()).thenAnswer((_) async => true);

      final result = await repo.isLoggedIn();
      expect(result, true);
    });

    test('returns false when no token', () async {
      when(() => mockToken.isLoggedIn()).thenAnswer((_) async => false);

      final result = await repo.isLoggedIn();
      expect(result, false);
    });
  });
}
