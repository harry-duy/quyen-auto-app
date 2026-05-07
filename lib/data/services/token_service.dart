import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _keyAccess  = 'qa_access_token';
  static const _keyRefresh = 'qa_refresh_token';
  static const _keyRole    = 'qa_user_role';

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage;

  TokenService()
      : _storage = const FlutterSecureStorage(
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        );

  // ─── Write ─────────────────────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccess, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefresh, value: token);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _keyRole, value: role);

  // ─── Read ──────────────────────────────────────────────────────────────────

  Future<String?> getAccessToken()  => _storage.read(key: _keyAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);
  Future<String?> getUserRole()     => _storage.read(key: _keyRole);

  Future<bool> isLoggedIn() async =>
      (await getAccessToken()) != null;

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> clearAllTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccess),
      _storage.delete(key: _keyRefresh),
      _storage.delete(key: _keyRole),
    ]);
  }
}
