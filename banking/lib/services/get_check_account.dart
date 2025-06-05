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



class Transaction {
  final double amount;
  final String message;
  final DateTime timestamp;
  final String status;

  Transaction({
    required this.amount,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount'] as double,
      message: json['message'] as String,
      // Chuyển chuỗi ISO 8601 thành DateTime
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
    );
  }
}

class Messages {
  final String content;
  final DateTime createdAt;
  Messages({
    required this.content,
    required this.createdAt
  });

  factory Messages.fromJson(Map<String, dynamic> json){
    return Messages(
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String)
    );
  }
}

class GetMessages{
  final bool flag;
  final String message;
  final List<Messages> msgs;

  GetMessages({
    required this.flag,
    required this.message,
    required this.msgs,
  });

  factory GetMessages.fromJson(Map<String, dynamic> json) {
    var list = <Messages>[];
    if (json['msgs'] != null) {
      list = List<Map<String, dynamic>>.from(json['msgs'])
          .map((e) => Messages.fromJson(e))
          .toList();
    }
    return GetMessages(
      flag: json['flag'] as bool,
      message: json['message'] as String,
      msgs: list,
    );
  }
}

class GetHistoryResponse {
  final bool flag;
  final String message;
  final List<Transaction> trans;

  GetHistoryResponse({
    required this.flag,
    required this.message,
    required this.trans,
  });

  factory GetHistoryResponse.fromJson(Map<String, dynamic> json) {
    var list = <Transaction>[];
    if (json['trans'] != null) {
      list = List<Map<String, dynamic>>.from(json['trans'])
          .map((e) => Transaction.fromJson(e))
          .toList();
    }
    return GetHistoryResponse(
      flag: json['flag'] as bool,
      message: json['message'] as String,
      trans: list,
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
        fullname: "null",
      );
      // return CheckAccountResponse.fromJson(jsonResponse);
    }
  }


  Future<GetHistoryResponse> getHistory() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Chưa có token. Vui lòng đăng nhập để lấy token hợp lệ.');
    }

    final uri = Uri.parse('$_baseUrl/getHistory');
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: '' ,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return GetHistoryResponse.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return GetHistoryResponse(
        flag: jsonResponse['flag'] as bool,
        message: jsonResponse['message'] as String,
        trans: [],
      );
    }
  }
  Future<GetMessages> getNotification() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Chưa có token. Vui lòng đăng nhập để lấy token hợp lệ.');
    }

    final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Notification/getHistoryNotification');
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: '' ,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return GetMessages.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return GetMessages.fromJson(jsonResponse);
    }
  }
}
