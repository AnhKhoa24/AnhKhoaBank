import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:banking/services/check_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/list_tile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserInfo();
  }


  Future<Map<String, dynamic>> _fetchUserInfo() async {
    final token = await AuthService().getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token trong SharedPreferences');
    }

    final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Home/me');
    final response = await http.get(
      uri,
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body;
    } else {
      throw Exception('Lỗi khi lấy thông tin người dùng: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scaffoldColor,
        title: Text(
          'Thông tin cá nhân',
          style: mediumTextStyle,
        ),
      ),
      body: Center(
        child: Padding(
          padding: REdgeInsets.all(24.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Hiển thị loading indicator trong khi chờ API trả về
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Hiển thị lỗi (nếu có) để debug
                return Text(
                  'Đã có lỗi: ${snapshot.error}',
                  // style: redTextStyle,
                );
              } else if (snapshot.hasData) {
                final user = snapshot.data!;
                final fullName = user['fullName'] as String? ?? '';
                final email = user['email'] as String? ?? '';

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      badges.Badge(
                        badgeContent:
                            SvgPicture.asset('assets/svg/pencil_icon.svg'),
                        showBadge: true,
                        position: badges.BadgePosition.bottomEnd(),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: secondaryFocusColor,
                          padding: REdgeInsets.all(8),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(6.r)),
                          child: Image.asset(
                            'assets/images/profile_picture.png',
                            width: 100.w,
                            height: 100.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        fullName,
                        style: largeTextStyle,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        email,
                        style: xSmallTextStyle,
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        padding: REdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(6.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Xác thực thông tin',
                              style:
                                  smallTextStyle.copyWith(color: whiteColor),
                            ),
                            CircularPercentIndicator(
                              radius: 20.0,
                              lineWidth: 5.0,
                              percent: 0.5,
                              backgroundColor: whiteColor,
                              progressColor: secondaryFocusColor,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Cài đặt',
                          style: mediumTextStyle,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ListTileCard(
                        iconPath: 'assets/svg/manage_notif_icon.svg',
                        title: 'Quản lý thông báo',
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RouteGenerator.manageNotificationPage,
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                      ListTileCard(
                        iconPath: 'assets/svg/security_icon.svg',
                        title: 'Bảo mật',
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RouteGenerator.securityPage,
                          );
                        },
                      ),
                      SizedBox(height: 10.h),
                      ListTileCard(
                        iconPath: 'assets/svg/logout_icon.svg',
                        title: 'Đăng xuất',
                        onTap: () {
                          AuthService().clearToken();
                          Navigator.of(context).pushNamed(
                            RouteGenerator.loginPage,
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox(); // Trường hợp không có data lẫn lỗi
              }
            },
          ),
        ),
      ),
    );
  }
}
