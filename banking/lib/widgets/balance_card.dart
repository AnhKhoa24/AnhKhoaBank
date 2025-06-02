// lib/widgets/balance_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

class BalanceCard extends StatelessWidget {
  final String balanceText;
  final String accountText;

  const BalanceCard({
    Key? key,
    required this.balanceText,
    required this.accountText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 10.h,
            left: 5.w,
            right: 5.w,
            child: Container(
              width: 319.w,
              height: 88.h,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 150, 199, 15),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 3327.w,
              height: 88.h,
              decoration: BoxDecoration(
                color: const Color.fromARGB(224, 24, 147, 5),
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
              ),
            ),
          ),
          Positioned(
            child: SvgPicture.asset(
              'assets/svg/dashboard_card.svg',
              colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
            ),
          ),
          Positioned(
            child: RPadding(
              padding: REdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số dư tài khoản',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const Icon(
                        Icons.more_horiz,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Thay Text bằng RichText để chèn thêm 'đ' nhỏ và hơi nâng lên
                      RichText(
                        text: TextSpan(
                          text: balanceText, // ví dụ "1,245,443 "
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Transform.translate(
                                offset: const Offset(0, -4), // nâng 'đ' lên 4px
                                child: const Text(
                                  ' vnđ',
                                  style: TextStyle(
                                    fontSize:
                                        14, // nhỏ hơn fontSize của balanceText
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Phần accountText giữ nguyên
                      Text(
                        accountText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
