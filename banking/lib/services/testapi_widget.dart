// lib/pages/test_api_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/constants.dart';

// Import UserProfile và UserService
import 'models/user_profile.dart';
import '../services/getdash_board_user.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({Key? key}) : super(key: key);

  @override
  _TestApiPageState createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  UserProfile? _profile;
  String? _error;
  bool _isLoading = false;

  Future<void> _callApi() async {
    setState(() {
      _isLoading = true;
      _profile = null;
      _error = null;
    });

    final result = await UserService.fetchUserProfile();

    if (result == null) {
      setState(() {
        _isLoading = false;
        _error = 'Không lấy được thông tin user (null hoặc lỗi)';
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _profile = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Page'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _callApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Test fetchUserProfile()',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            // Nếu có lỗi, hiển thị
            if (_error != null)
              Text(
                _error!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              ),

            // Nếu có profile, hiển thị từng trường
            if (_profile != null) ...[
              _buildRow('ID', _profile!.id),
              _buildRow('Email', _profile!.email),
              _buildRow('Full Name', _profile!.fullName),
              _buildRow('Role', _profile!.role),
              _buildRow('Account Number', _profile!.accountNumber),
              _buildRow('Balance', _profile!.balance.toString()),
              _buildRow('Created At', _profile!.createdAt.toIso8601String()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
