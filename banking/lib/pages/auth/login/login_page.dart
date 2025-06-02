import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/components/c_elevated_button.dart';
import '/components/c_text_form_field.dart';
import '/components/secondary_button.dart';
import '/providers/password_provider.dart';
import '/utils/constants.dart';
import '/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '/pages/auth/login/verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _passwordController = TextEditingController();
  final _accountController = TextEditingController();

  bool _isLoading = false; // <-- Biến để theo dõi trạng thái loading

  @override
  void dispose() {
    _passwordController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại hoặc email'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Bật loading trước khi gọi API
    });

    final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account': account,
          'password': password,
        }),
      );

      if (!mounted) return; // Kiểm tra widget còn tồn tại không

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final emailFromApi = data['email'] as String;

        // Chuyển sang VerificationPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationPage(email: emailFromApi),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng nhập thất bại: ${response.reasonPhrase} (HTTP ${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối đến máy chủ: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Tắt loading khi đã hoàn thành
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                Image.asset(
                  'assets/images/anhkhoabank.png',
                  width: 200.w,
                  height: 160.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10.h),
                Text('Chào mừng bạn trở lại!', style: largeTextStyle),
                SizedBox(height: 8.h),
                Text(
                  'Đăng nhập hoặc đăng ký tài khoản để tiếp tục trải nghiệm dịch vụ',
                  style: xSmallTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60.h),
                CTextFormField(
                  hintText: 'E-mail/Số điện thoại',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textControllor: _accountController,
                ),
                SizedBox(height: 20.h),
                Consumer<PasswordProvider>(
                  builder: (context, pp, child) {
                    return CTextFormField(
                      textControllor: _passwordController,
                      obscureText: pp.isObscure,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      hintText: 'Mật khẩu',
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
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Quên mật khẩu?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF767D88),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: CElevatedButton(
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Đăng Nhập'),
                    onPressed: _isLoading
                        ? () {
                            // Nếu đang loading, không làm gì
                            return;
                          }
                        : () {
                            _handleLogin();
                          },
                  ),
                ),
                SizedBox(height: 16.h),
                Text('Or Sign In with', style: xSmallTextStyle),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    child: const Text('Google'),
                    onPressed: () {},
                  ),
                ),
                SizedBox(height: 24.h),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(RouteGenerator.registerPage);
                  },
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text.rich(
                      textAlign: TextAlign.left,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Not Register? ',
                            style: xSmallTextStyle,
                          ),
                          TextSpan(
                            text: 'Create an Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF160D07),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
