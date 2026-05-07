import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authorization/user_model.dart';
import 'session.dart';

class SessionStorage {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';

  Future<void> save(Session session) async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.write(key: _tokenKey, value: session.token);
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  Future<Session?> get() async {
    final prefs = await SharedPreferences.getInstance();

    final token = await _secure.read(key: _tokenKey);
    final userString = prefs.getString(_userKey);

    if (token == null || userString == null) return null;

    return Session(
      token: token,
      user: UserModel.fromJson(jsonDecode(userString)),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.delete(key: _tokenKey);
    await prefs.remove(_userKey);
  }
}