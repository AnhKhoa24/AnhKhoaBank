import 'package:banking/pages/auth/login/login_finger_print_page.dart';
import 'package:banking/pages/card/card_page.dart';
import 'package:banking/widgets/balance_card_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';
import '/utils/constants.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../utils/routes.dart';
import '../../services/getdash_board_user.dart';
import '/services/models/user_profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<UserProfile?> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = UserService.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldColor,
        title: Padding(
          padding: REdgeInsets.only(left: 5.w),
          child: FutureBuilder<UserProfile?>(
            future: _futureProfile,
            builder: (context, snapshot) {
              // Nếu vẫn loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF160D07),
                      ),
                    ),
                    Text('User...!', style: smallTextStyle),
                  ],
                );
              }

              // Nếu lỗi hoặc null
              if (snapshot.hasError || snapshot.data == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF160D07),
                      ),
                    ),
                    Text('User!', style: smallTextStyle),
                  ],
                );
              }

              // Thành công: có profile
              final profile = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Xin chào ",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF160D07),
                    ),
                  ),
                  Text('${profile.fullName}!', style: smallTextStyle),
                ],
              );
            },
          ),
        ),
        actions: [
          InkWell(
            onTap:
                () => Navigator.of(
                  context,
                ).pushNamed(RouteGenerator.notificationPage),
            child: Container(
              margin: REdgeInsets.all(5),
              padding: REdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: kDefaultBoxShadow,
                color: whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(3.r)),
              ),
              child: SvgPicture.asset('assets/svg/notifications_icon.svg'),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: REdgeInsets.all(24),
        children: [
          // Hiển thị BalanceCard dựa trên kết quả fetch API
          const BalanceCardLoader(),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _card('assets/svg/send_icon.svg', 'Chuyển tiền', () {
                Navigator.of(context).pushNamed(RouteGenerator.transferPage);
              }),
              _cardImages('assets/images/icons8-qr-48.png', 'QR nhận tiền', () {
                // Navigator.of(context).pushNamed(RouteGenerator.qrCodePage);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrCodeWidget()),
                );
              }),
              _card('assets/svg/withdraw_icon.svg', 'Thẻ', () {
                // Navigator.of(context).pushNamed(RouteGenerator.addCardPage);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardPage()),
                );
              }),
              _card('assets/svg/bill_icon.svg', 'Khác', () {
                Navigator.of(context).pushNamed(RouteGenerator.paymentPage);
              }),
            ],
          ),
          SizedBox(height: 24.h),
          Text('Chuyển tiền bạn bè', style: mediumTextStyle),
          SizedBox(height: 16.h),
          Row(
            children: [
              DottedBorder(
                color: const Color(0xFF767D88),
                strokeCap: StrokeCap.butt,
                borderType: BorderType.RRect,
                strokeWidth: 1,
                radius: Radius.circular(6.r),
                padding: REdgeInsets.all(16),
                child: const Icon(Icons.add, color: Color(0xFF767D88)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 7,
                    padding: REdgeInsets.all(0),
                    itemBuilder:
                        (context, index) => Container(
                          width: 56.w,
                          height: 56.h,
                          margin: REdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                            child: Image.asset(
                              'assets/images/friends_image.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text('Về chúng tôi', style: mediumTextStyle),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              image: DecorationImage(
                image: AssetImage('assets/images/banner2.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: 24.h),
          // DottedBorder(
          //   color: const Color(0xFF767D88),
          //   strokeCap: StrokeCap.butt,
          //   dashPattern: const [8, 6],
          //   borderType: BorderType.RRect,
          //   strokeWidth: 1,
          //   radius: Radius.circular(6.r),
          //   padding: REdgeInsets.all(16),
          //   child: InkWell(
          //     onTap: () {
          //       Navigator.of(context).pushNamed(RouteGenerator.addSavingPage);
          //     },
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Icon(Icons.add, color: Color(0xFF767D88)),
          //         SizedBox(width: 50.w),
          //         Text(
          //           'Add Saving',
          //           style: GoogleFonts.plusJakartaSans(
          //             fontSize: 14.sp,
          //             fontWeight: FontWeight.w600,
          //             color: const Color(0xFF767D88),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _card(String icon, String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            padding: REdgeInsets.symmetric(vertical: 22.h),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: SvgPicture.asset(icon, width: 20.w, height: 20.h),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF767D88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardImages(String icon, String title, Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            padding: REdgeInsets.symmetric(vertical: 22.h),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: Image.asset(icon, width: 20.w, height: 20.h),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF767D88),
            ),
          ),
        ],
      ),
    );
  }
}
