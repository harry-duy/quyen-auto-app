import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String phone, required String password});
  Future<User> register({required String fullName, required String phone, required String password, String? email});
  Future<User> loginWithZalo(String zaloCode);
  Future<User> getProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
}
