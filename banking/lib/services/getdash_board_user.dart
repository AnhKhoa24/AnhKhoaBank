import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_profile.dart'; 

class UserService {
  static const _baseUrl = 'https://anhkhoa.tryasp.net/api/Home/me';

  static Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<UserProfile?> fetchUserProfile() async {
    try {
      final token = await _getSavedToken();
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse(_baseUrl);
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      } else {
        return null;
      }
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }
}
