import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Authorization/user_model.dart';

class UserLocalStorage {
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('current_user', userJson);
  }

  Future <UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');

    if (userString == null){
      return null;
    }
    final userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap);
  }
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
}
