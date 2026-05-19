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
    final userJson = (d['user'] as Map<String, dynamic>?) ?? d;
    await _saveRoleIfPresent(userJson);
    return _mapUser(userJson);
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
    final userJson = (d['user'] as Map<String, dynamic>?) ?? d;
    await _saveRoleIfPresent(userJson);
    return _mapUser(userJson);
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
    final userJson = (d['user'] as Map<String, dynamic>?) ?? d;
    await _saveRoleIfPresent(userJson);
    return _mapUser(userJson);
  }

  @override
  Future<User> getProfile() async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiConstants.profile,
      fromData: (json) => json as Map<String, dynamic>,
    );
    final user = _mapUser(res.data!);
    await _tokenService.saveUserRole(user.role.name.toUpperCase());
    return user;
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

  Future<void> _saveRoleIfPresent(Map<String, dynamic> d) async {
    final role = d['role'] as String?;
    if (role != null) {
      await _tokenService.saveUserRole(role);
    }
  }

  User _mapUser(Map<String, dynamic> j) => User(
    id:             (j['id'] ?? '').toString(),
    fullName:       j['fullName']       as String? ?? '',
    phone:          j['phone']          as String? ?? '',
    email:          j['email']          as String?,
    avatarUrl:      j['avatarUrl']      as String?,
    role:           UserRole.fromString(j['role'] as String?),
    isActive:       j['isActive']       as bool? ?? true,
    departmentId:   (j['departmentId'])?.toString(),
    departmentName: j['departmentName'] as String?,
    position:       j['position']       as String?,
    employeeCode:   j['employeeCode']   as String?,
  );
}
