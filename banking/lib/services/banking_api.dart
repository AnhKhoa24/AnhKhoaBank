import 'dart:convert';
import 'package:banking/services/check_token.dart';
import 'package:http/http.dart' as http;

class TranferResponse {
  final bool success;
  final String message;

  TranferResponse({
    required this.success,
    required this.message,
  });

  factory TranferResponse.fromJson(Map<String, dynamic> json) {
    return TranferResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}

class TranferService {
  static const _baseUrl = 'https://anhkhoa.tryasp.net/api/Banking';

  final AuthService _authService = AuthService();

  Future<TranferResponse> transfer({
    required String accountNumber,
    required double amount,
    required String message,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Chưa có token. Vui lòng đăng nhập để lấy token hợp lệ.');
    }

    final uri = Uri.parse('$_baseUrl/tranfer');
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'toAccountNumber': accountNumber,
      'amount': amount,
      'message':message
    });

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TranferResponse.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TranferResponse.fromJson(jsonResponse);
    }
  }
}
