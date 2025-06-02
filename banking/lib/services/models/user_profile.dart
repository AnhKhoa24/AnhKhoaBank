class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String accountNumber;
  final int balance;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.accountNumber,
    required this.balance,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      accountNumber: json['accountNumber'] as String,
      balance: (json['balance'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'accountNumber': accountNumber,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
