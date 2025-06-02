import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/c_elevated_button.dart';
import '/providers/confirm_password_provider.dart';

import '../../../components/c_text_form_field.dart';
import '../../../components/phone_number_field.dart';
import '../../../providers/password_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/routes.dart';

// Thêm import để gọi HTTP và encode JSON
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers cho từng ô nhập
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Để quản lý loading state (tùy chọn)
  bool _isLoading = false;

  @override
  void dispose() {
    // Nhớ dispose các controller khi Widget bị hủy
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm gọi API đăng ký
  Future<void> _registerAccount() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate đơn giản (bạn có thể mở rộng thêm tuỳ ý)
    if (fullName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu và xác nhận mật khẩu không khớp'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Auth/register');
    final body = jsonEncode({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        // final data = jsonDecode(response.body);
       
        Navigator.of(
          context,
        ).pushNamed(RouteGenerator.registerSuccessPage);
      } else {
        // Nếu status code khác 200/201, parse lỗi và show SnackBar
        String message = 'Đăng ký thất bại';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            message = errorData['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message (HTTP ${response.statusCode})')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios, color: arrowBackColor),
        ),
        actions: [
          RPadding(
            padding: REdgeInsets.all(10.0),
            child: Text('Step 1 of 2', style: smallTextStyle),
          ),
          SizedBox(width: 10.w),
        ],
        leadingWidth: 50.w,
      ),
      body: SingleChildScrollView(
        child: RPadding(
          padding: REdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),

              Text('Tạo mới tài khoản', style: largeTextStyle),
              SizedBox(height: 8.h),
              Text(
                'Điền đầy đủ thông tin để tiếp tục bước đăng ký',
                style: xSmallTextStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.h),

              // Full Name
              CTextFormField(
                textControllor: _fullNameController,
                hintText: 'Tên đầy đủ',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20.h),

              // Email
              CTextFormField(
                textControllor: _emailController,
                hintText: 'Email',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),

              // Phone Number
              PhoneNumberField(
                textControllor: _phoneController,
                hintText: 'Số điện thoại',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                prefixIcon: Text('+84', style: hintTextStyle),
              ),
              SizedBox(height: 20.h),

              // Password
              Consumer<PasswordProvider>(
                builder: (context, pp, child) {
                  return CTextFormField(
                    textControllor: _passwordController,
                    obscureText: pp.isObscure,
                    hintText: 'Mật khẩu',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    suffixIcon: IconButton(
                      onPressed: () {
                        pp.toggleIsObscure();
                      },
                      icon: Icon(
                        pp.isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),

              // Confirm Password
              Consumer<ConfirmPasswordProvider>(
                builder: (context, cp, child) {
                  return CTextFormField(
                    textControllor: _confirmPasswordController,
                    obscureText: cp.isObscure,
                    hintText: 'Xác nhận lại mật khẩu',
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    suffixIcon: IconButton(
                      onPressed: () {
                        cp.toggleIsObscure();
                      },
                      icon: Icon(
                        cp.isObscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30.h),

              // Chính sách
              Align(
                alignment: Alignment.center,
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Bằng cách tiếp tục, bạn đồng ý rằng AKBank sẽ sử dụng dữ liệu của bạn như đã nêu trong ',
                        style: xSmallTextStyle,
                      ),
                      TextSpan(
                        text: 'Chính sách.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF160D07),
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () async {
                                const url = 'https://google.com';
                                launchURLFunction(url);
                              },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              // Nút “Tiếp tục” – kiểu onPressed luôn là void Function(), không bao giờ null
              SizedBox(
                width: double.infinity,
                child: CElevatedButton(
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Tiếp tục'),
                  onPressed: () {
                    // Nếu đang loading thì không làm gì cả
                    if (_isLoading) return;
                    // Ngược lại, gọi hàm đăng ký
                    _registerAccount();
                  },
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
