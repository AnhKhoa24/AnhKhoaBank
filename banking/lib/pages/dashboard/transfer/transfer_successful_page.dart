// lib/pages/transfer_successful_page.dart

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/c_elevated_button.dart';
import '/components/secondary_button.dart';
import '/utils/constants.dart';
import 'package:intl/intl.dart';

class TransferSuccessfulPage extends StatelessWidget {
  // Thêm các trường để lưu thông tin chuyển thành công:
  final String recipientName;
  final String recipientAccount;
  final double amount; // số tiền
  final DateTime timestamp; // thời điểm giao dịch

  const TransferSuccessfulPage({
    super.key,
    required this.recipientName,
    required this.recipientAccount,
    required this.amount,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Định dạng số tiền, ví dụ "2,900,000 vnđ"
    final formattedAmount = NumberFormat.decimalPattern().format(amount);

    // Định dạng ngày/thời gian, ví dụ "Tuesday, June 7, 2022 at 11:10 PM"
    final formattedDate = DateFormat(
      'EEEE, MMMM d, y \'at\' hh:mm a',
    ).format(timestamp);

    return Scaffold(
      backgroundColor: const Color(0xFFDBDBDB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFDBDBDB),
        leadingWidth: 100.w,
        title: Text('Transfer', style: mediumTextStyle),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20.r),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 84.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              height: 430.h,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(9.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 70.h),
                  Text('Chuyển tiền thành công', style: largeTextStyle),
                  SizedBox(height: 16.h),
                  // Bạn có thể dùng ảnh đại diện mặc định hoặc truyền đường dẫn nếu bạn có
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    child: Image.asset(
                      'assets/images/friends_image.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Hiển thị tên người nhận
                  Text(recipientName, style: mediumTextStyle),
                  SizedBox(height: 4.h),
                  // Hiển thị số tài khoản người nhận
                  Text(recipientAccount, style: xSmallTextStyle),
                  SizedBox(height: 16.h),
                  // Hiển thị số tiền đã chuyển
                  RichText(
                    text: TextSpan(
                      text: formattedAmount,
                      style: heading1,
                      children: [
                        WidgetSpan(
                          alignment:
                              PlaceholderAlignment
                                  .top, // để “vnđ” được nâng lên
                          child: Transform.translate(
                            // offset: (dx, dy).
                            // Ở đây chúng ta đẩy lên khoảng 30% chiều cao chữ gốc
                            offset: Offset(0, -heading1.fontSize! * 0.01),
                            child: Text(
                              ' vnđ',
                              style: heading1.copyWith(
                                fontSize:
                                    heading1.fontSize! *
                                    0.5, // chỉ bằng 50% size gốc
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),
                  SizedBox(height: 30.h),
                  // Hiển thị ngày giờ giao dịch
                  Text(formattedDate, style: xSmallTextStyle),
                  SizedBox(height: 20.h),
                  Text('View transaction details', style: mediumTextStyle),
                ],
              ),
            ),
          ),
          Positioned(
            top: 402.h,
            left: 14.w,
            right: 14.w,
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBDBDB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Expanded(
                    child: DottedLine(
                      dashColor: Color(0xFFE1E2E5),
                      dashLength: 6,
                    ),
                  ),
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBDBDB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 34.h,
            left: 137.w,
            right: 137.w,
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: secondaryColor,
              child: SvgPicture.asset('assets/svg/star_icon.svg'),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CElevatedButton(
                    child: const Text('Back To Home'),
                    onPressed: () {
                      // Quay về màn hình chính
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    child: Text(
                      'Send Again',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: secondaryButtonTextColor,
                      ),
                    ),
                    onPressed: () {
                      // Quay ngược về trang chuyển tiền trước đó
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
