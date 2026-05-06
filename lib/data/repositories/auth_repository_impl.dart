import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService   _api;
  final TokenService _tokenService;

  AuthRepositoryImpl(this._api, this._tokenService);

  @override
  Future<User> login({required String phone, required String password}) async {
    final res = await _api.post<Map<String, dynamic>>(
      'auth/login',
      data: {'phone': phone, 'password': password},
      fromData: (json) => json as Map<String, dynamic>,
    );
    final d = res.data!;
    if (d['accessToken']  != null) await _tokenService.saveAccessToken(d['accessToken']  as String);
    if (d['refreshToken'] != null) await _tokenService.saveRefreshToken(d['refreshToken'] as String);
    return _mapUser(d);
  }

  @override
  Future<User> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      'auth/register',
      data: {
        'fullName': fullName,
        'phone':    phone,
        'password': password,
        if (email != null) 'email': email,
      },
      fromData: (json) => json as Map<String, dynamic>,
    );
    return _mapUser(res.data!);
  }

  @override
  Future<User> loginWithZalo(String zaloCode) async {
    final res = await _api.post<Map<String, dynamic>>(
      'auth/zalo',
      data: {'code': zaloCode},
      fromData: (json) => json as Map<String, dynamic>,
    );
    final d = res.data!;
    if (d['accessToken']  != null) await _tokenService.saveAccessToken(d['accessToken']  as String);
    if (d['refreshToken'] != null) await _tokenService.saveRefreshToken(d['refreshToken'] as String);
    return _mapUser(d);
  }

  @override
  Future<void> logout() => _tokenService.clearAllTokens();

  @override
  Future<bool> isLoggedIn() => _tokenService.isLoggedIn();

  User _mapUser(Map<String, dynamic> j) => User(
    id:        j['id']        as String,
    fullName:  j['fullName']  as String,
    phone:     j['phone']     as String,
    email:     j['email']     as String?,
    avatarUrl: j['avatarUrl'] as String?,
    role:      j['role']      as String,
  );
}
