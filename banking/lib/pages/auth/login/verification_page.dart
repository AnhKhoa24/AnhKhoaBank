// lib/pages/auth/verification_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';
import '../../../utils/routes.dart';
import '/services/device_service.dart'; // <-- import service

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final _otpFormKey = GlobalKey<FormState>();

  bool _isVerifying = false; // để hiển thị loading overlay

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isVerifying = true);

    // Lấy FCM token & deviceInfo nếu cần
    final fcmToken = await DeviceService.getFcmToken();
    final deviceInfo = await DeviceService.getDeviceInfoString();

    final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Auth/otpVerified');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otp,
          'fcmToken': fcmToken,
          'deviceInfo': deviceInfo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        if (!mounted) return;
        // Chuyển sang màn hình chính
        Navigator.of(context).pushReplacementNamed(RouteGenerator.navigationPage);
        // Navigator.of(context).pushReplacementNamed(RouteGenerator.testApiPage);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP không hợp lệ hoặc đã hết hạn')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xác thực OTP: $e')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Colors.transparent;
    const borderColor = Colors.transparent;

    final defaultPinTheme = PinTheme(
      width: 44.w,
      height: 64.h,
      textStyle: heading2,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF0),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios,
            color: arrowBackColor,
          ),
        ),
        leadingWidth: 50.w,
      ),

      // Dùng Stack để chồng nội dung chính và overlay loading
      body: Stack(
        children: [
          // === Nội dung chính của màn hình ===
          Center(
            child: Padding(
              padding: REdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Xác thực email', style: largeTextStyle),
                  SizedBox(height: 8.h),
                  Text(
                    'Nhập OTP được gửi đến email:',
                    style: xSmallTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Text(widget.email, style: mediumTextStyle),
                  SizedBox(height: 52.h),
                  Form(
                    key: _otpFormKey,
                    child: Column(
                      children: [
                        Pinput(
                          controller: pinController,
                          length: 6,
                          focusNode: focusNode,
                          defaultPinTheme: defaultPinTheme,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          keyboardType: TextInputType.number,
                          onCompleted: (pin) {
                            _verifyOtp(pin);
                          },
                          onChanged: (value) {
                            debugPrint('onChanged: $value');
                          },
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                width: 1.w,
                                height: 30.h,
                                color: primaryColor,
                              ),
                            ],
                          ),
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/svg/time_icon.svg'),
                            SizedBox(width: 8.w),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: 'Resend In ', style: xSmallTextStyle),
                                  TextSpan(
                                    text: '00:44',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF160D07),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // === Overlay loading (hiển thị khi _isVerifying == true) ===
          if (_isVerifying)
            Positioned.fill(
              child: Container(
               color: const Color.fromRGBO(0, 0, 0, 0.4), // nền mờ tối
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white, // hoặc primaryColor
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
