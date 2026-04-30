import '../Authorization/user_model.dart';
import '../services/token_storage.dart';
import '../services/user_local_storage.dart';

class AuthRepository {
  final TokenStorage tokenStorage;
  final UserLocalStorage userLocalStorage;

  AuthRepository({
    required this.tokenStorage,
    required this.userLocalStorage,
});

  Future<void> saveLoginData({
    required String token,
    required UserModel user,
}) async {
    await tokenStorage.saveToken(token);
    await userLocalStorage.saveUser(user);
  }

  Future<String?> getToken() async {
    return await tokenStorage.getToken();

  }

  Future<void>logout() async {
    await tokenStorage.clearToken();
    await userLocalStorage.clearUser();
  }
}

