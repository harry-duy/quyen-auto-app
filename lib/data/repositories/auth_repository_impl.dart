import '../../core/constants/api_constants.dart';
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
      ApiConstants.login,
      data: {'phone': phone, 'password': password},
      fromData: (json) => json as Map<String, dynamic>,
    );
    final d = res.data!;
    await _saveTokensIfPresent(d);
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
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'phone':    phone,
        'password': password,
        if (email != null) 'email': email,
      },
      fromData: (json) => json as Map<String, dynamic>,
    );
    final d = res.data!;
    await _saveTokensIfPresent(d);
    return _mapUser(d);
  }

  @override
  Future<User> loginWithZalo(String zaloCode) async {
    final res = await _api.post<Map<String, dynamic>>(
      ApiConstants.zaloAuth,
      data: {'code': zaloCode},
      fromData: (json) => json as Map<String, dynamic>,
    );
    final d = res.data!;
    await _saveTokensIfPresent(d);
    return _mapUser(d);
  }

  @override
  Future<User> getProfile() async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiConstants.profile,
      fromData: (json) => json as Map<String, dynamic>,
    );
    return _mapUser(res.data!);
  }

  @override
  Future<void> logout() => _tokenService.clearAllTokens();

  @override
  Future<bool> isLoggedIn() => _tokenService.isLoggedIn();

  Future<void> _saveTokensIfPresent(Map<String, dynamic> d) async {
    final access = d['accessToken'] as String?;
    final refresh = d['refreshToken'] as String?;
    if (access != null && refresh != null) {
      await _tokenService.saveTokens(
          accessToken: access, refreshToken: refresh);
    } else {
      if (access != null) await _tokenService.saveAccessToken(access);
      if (refresh != null) await _tokenService.saveRefreshToken(refresh);
    }
  }

  User _mapUser(Map<String, dynamic> j) => User(
    id:        (j['id'] ?? '').toString(),
    fullName:  j['fullName']  as String? ?? '',
    phone:     j['phone']     as String? ?? '',
    email:     j['email']     as String?,
    avatarUrl: j['avatarUrl'] as String?,
    role:      j['role']      as String? ?? '',
  );
}
