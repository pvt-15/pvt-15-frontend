import 'package:Skogsjakten/services/session_storage.dart';
import 'package:http/http.dart' as http;

class CheckCurrentUser {

  Future<bool> checkValidToken() async {
    final String? storedToken = await SessionStorage().getToken();

    if (storedToken == null) return false;

    try {
      final response = await http.get(
        Uri.parse('https://group-6-15.pvt.dsv.su.se/auth/me'),
        headers: {
          'Authorization': 'Bearer $storedToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

    } catch (e) {
      return false;
    }
  }
}