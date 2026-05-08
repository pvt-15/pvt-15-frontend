import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authorization/user_model.dart';
import 'session.dart';

class SessionStorage {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';

  Future<void> saveUser(Session session) async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.write(key: _tokenKey, value: session.token);
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  Future<Session?> getUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = await _secure.read(key: _tokenKey);
    final userString = prefs.getString(_userKey);

    if (token == null || userString == null) return null;

    return Session(
      token: token,
      user: UserModel.fromJson(jsonDecode(userString)),
    );
  }

  Future<String?> getToken() async {
    final token = await _secure.read(key: _tokenKey);

    return token;
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');

    if (userString == null){
      return null;
    }

    final userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.delete(key: _tokenKey);
    await prefs.remove(_userKey);
  }
}