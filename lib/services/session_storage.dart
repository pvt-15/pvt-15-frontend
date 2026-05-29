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

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<Session?> getUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = await _secure.read(key: _tokenKey);
    final userString = prefs.getString(_userKey);

    if (token == null || userString == null) return null;

    try {
      return Session(
        token: token,
        user: UserModel.fromJson(jsonDecode(userString)),
      );
    } catch (e) {
      await prefs.remove(_userKey);
      return null;
    }
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    try {
      final userMap = jsonDecode(userString);
      return UserModel.fromJson(userMap);
    } catch (e) {
      await prefs.remove(_userKey);
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _secure.read(key: _tokenKey);
  }

  Future<void> saveIsGoogleUser(bool isGoogle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_google_user', isGoogle);
  }

  Future<bool> getIsGoogleUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_google_user') ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.delete(key: _tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('is_google_user');
  }
}



/* version som finns i dev, appen vägrar ladda.
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

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
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

  /*Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');

    if (userString == null){
      return null;
    }*/

    Future<UserModel?> getUser() async {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('current_user');

      if (userString == null) return null;

      try {
        final userMap = jsonDecode(userString);
        return UserModel.fromJson(userMap);
      } catch (e) {
        await prefs.remove('current_user');
        return null;
      }
    }



    // lägger till en catch
    try {
      final userMap = jsonDecode(userString);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await _secure.delete(key: _tokenKey);
    await prefs.remove(_userKey);
  }
}

 */