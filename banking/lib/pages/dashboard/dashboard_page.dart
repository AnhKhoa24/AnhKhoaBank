import 'package:banking/widgets/balance_card_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '/utils/constants.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../utils/routes.dart';
import '../../widgets/balance_card.dart';

// Import UserService và model
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

  String _formatBalance(int balance) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(balance);
  }

  String _maskAccountNumber(String accountNumber) {
    final length = accountNumber.length;

    if (length <= 3) {
      return accountNumber;
    } else if (length <= 6) {
      final part1 = accountNumber.substring(0, 3);
      final part2 = accountNumber.substring(3);
      return '$part1 $part2';
    } else {
      final part1 = accountNumber.substring(0, 3);
      final part2 = accountNumber.substring(3, 6);
      final part3 = accountNumber.substring(6);
      return '$part1 $part2 $part3';
    }
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
              _card('assets/svg/send_icon.svg', 'Transfer', () {
                Navigator.of(context).pushNamed(RouteGenerator.transferPage);
              }),
              _card('assets/svg/recieve_icon.svg', 'Receive', () {
                Navigator.of(
                  context,
                ).pushNamed(RouteGenerator.loginFingerprintPage);
              }),
              _card('assets/svg/withdraw_icon.svg', 'Withdraw', () {
                Navigator.of(context).pushNamed(RouteGenerator.withdrawPage);
              }),
              _card('assets/svg/bill_icon.svg', 'Payment', () {
                Navigator.of(context).pushNamed(RouteGenerator.paymentPage);
              }),
            ],
          ),
          SizedBox(height: 24.h),
          Text('Send to Friends', style: mediumTextStyle),
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
          Text('Savings', style: mediumTextStyle),
          SizedBox(height: 16.h),
          Container(
            padding: REdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: kDefaultBoxShadow,
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: REdgeInsets.all(0),
                  leading: Image.asset('assets/images/macbook_pro_image.png'),
                  title: Text('Macbook Pro M1 Max 1TB', style: smallTextStyle),
                  subtitle: Text('\$200/\$2,000', style: xSmallTextStyle),
                  trailing: InkWell(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(RouteGenerator.savingPage);
                    },
                    child: const Icon(Icons.more_horiz),
                  ),
                ),
                SizedBox(height: 18.h),
                LinearPercentIndicator(
                  width: 295.w,
                  lineHeight: 14.0,
                  percent: 0.5,
                  backgroundColor: const Color(0xFFEDEEF0),
                  progressColor: yellowColor,
                  barRadius: Radius.circular(17.r),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          DottedBorder(
            color: const Color(0xFF767D88),
            strokeCap: StrokeCap.butt,
            dashPattern: const [8, 6],
            borderType: BorderType.RRect,
            strokeWidth: 1,
            radius: Radius.circular(6.r),
            padding: REdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(RouteGenerator.addSavingPage);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF767D88)),
                  SizedBox(width: 50.w),
                  Text(
                    'Add Saving',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF767D88),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
}
