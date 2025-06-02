import 'dart:convert';
import 'package:banking/services/check_token.dart';
import 'package:http/http.dart' as http;

class CheckAccountResponse {
  final bool success;
  final String message;
  final String fullname;

  CheckAccountResponse({
    required this.success,
    required this.message,
    required this.fullname,
  });

  factory CheckAccountResponse.fromJson(Map<String, dynamic> json) {
    return CheckAccountResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      fullname: json['fullname'] as String,
    );
  }
}

class BankingService {
  static const _baseUrl = 'https://anhkhoa.tryasp.net/api/Banking';

  final AuthService _authService = AuthService();

  Future<CheckAccountResponse> checkAccount({
    required String accountNumber,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Chưa có token. Vui lòng đăng nhập để lấy token hợp lệ.');
    }

    final uri = Uri.parse('$_baseUrl/checkAccount');
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'accountNumber': accountNumber,
    });

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return CheckAccountResponse.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return CheckAccountResponse(
        success: jsonResponse['success'] as bool,
        message: jsonResponse['message'] as String,
        fullname: jsonResponse['message'] as String,
      );
    }
  }
}
