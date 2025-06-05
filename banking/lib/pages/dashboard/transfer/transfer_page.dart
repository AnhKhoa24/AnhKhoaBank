import 'package:banking/services/get_check_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/constants.dart';
import '../../../utils/routes.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late final BankingService _bankingService;
  late Future<GetHistoryResponse> _futureHistory;

  @override
  void initState() {
    super.initState();
    // Khởi tạo BankingService với AuthService và httpClient bình thường
    _bankingService = BankingService();
    // Gọi API ngay khi widget được dựng
    _futureHistory = _bankingService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scaffoldColor,
        leadingWidth: 100.w,
        title: Text('Chuyển tiền', style: mediumTextStyle),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20.r),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: REdgeInsets.all(24),
        children: [
          // // Phần "Gần đây" vẫn giống cũ…
          // Text('Gần đây', style: mediumTextStyle),
          // SizedBox(height: 16.h),
          // Row(
          //   children: [
          //     Container(
          //       height: 56.h,
          //       width: 56.w,
          //       padding: REdgeInsets.all(14),
          //       decoration: BoxDecoration(
          //         color: primaryColor,
          //         borderRadius: BorderRadius.all(Radius.circular(6.r)),
          //       ),
          //       child: SvgPicture.asset('assets/svg/search_icon.svg'),
          //     ),
          //     SizedBox(width: 12.w),
          //     Expanded(
          //       child: SizedBox(
          //         height: 56.h,
          //         child: ListView.builder(
          //           shrinkWrap: true,
          //           scrollDirection: Axis.horizontal,
          //           physics: const BouncingScrollPhysics(),
          //           itemCount: 7,
          //           padding: REdgeInsets.all(0),
          //           itemBuilder:
          //               (context, index) => InkWell(
          //                 onTap: () {
          //                   Navigator.of(
          //                     context,
          //                   ).pushNamed(RouteGenerator.transferToFriendsPage);
          //                 },
          //                 child: Container(
          //                   width: 56.w,
          //                   height: 56.h,
          //                   margin: REdgeInsets.only(right: 12.w),
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.all(
          //                       Radius.circular(10.r),
          //                     ),
          //                   ),
          //                   child: ClipRRect(
          //                     borderRadius: BorderRadius.all(
          //                       Radius.circular(10.r),
          //                     ),
          //                     child: Image.asset(
          //                       'assets/images/friends_image.png',
          //                       fit: BoxFit.fill,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          // Phần "Chuyển khoản ngân hàng"…
          SizedBox(height: 24.h),
          Text('Chuyển khoản ngân hàng', style: mediumTextStyle),
          SizedBox(height: 16.h),
          Container(
            padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F6),
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: ListTile(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(RouteGenerator.transferBankPage);
              },
              contentPadding: REdgeInsets.all(0),
              leading: SvgPicture.asset('assets/svg/bank_card_icon.svg'),
              title: Text(
                'Anh Khoa Bank',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF160D07),
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
                size: 15.r,
              ),
            ),
          ),

          // Phần "Lịch sử chuyển tiền" – dùng FutureBuilder để load từ API
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lịch sử chuyển tiền', style: mediumTextStyle),
              const Icon(Icons.more_horiz, color: primaryColor),
            ],
          ),
          SizedBox(height: 16.h),

          // Dùng FutureBuilder để kiểm soát loading / success / error
          FutureBuilder<GetHistoryResponse>(
            future: _futureHistory,
            builder: (context, snapshot) {
              // 1) Khi đang load
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: REdgeInsets.symmetric(vertical: 40.h),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                );
              }

              // 2) Nếu có lỗi trong quá trình gọi API
              if (snapshot.hasError) {
                // In ra error để debug
                debugPrint('getHistory error: ${snapshot.error}');
                return Center(
                  child: Padding(
                    padding: REdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'Đã có lỗi xảy ra:\n${snapshot.error}',
                      style: smallTextStyle.copyWith(color: redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // 3) Khi đã load xong (snapshot.hasData == true)
              final GetHistoryResponse response = snapshot.data!;

              // 3.1) Nếu flag == false (server trả về thất bại)
              if (!response.flag) {
                return Center(
                  child: Padding(
                    padding: REdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      response.message,
                      style: smallTextStyle.copyWith(color: redColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // 3.2) Khi thành công, lấy list Transaction
              final List<Transaction> listTrans = response.trans;
              if (listTrans.isEmpty) {
                return Center(
                  child: Padding(
                    padding: REdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'Chưa có giao dịch nào.',
                      style: smallTextStyle,
                    ),
                  ),
                );
              }

              // 3.3) Render ListView.builder theo đúng dữ liệu:
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listTrans.length,
                itemBuilder: (context, index) {
                  final tx = listTrans[index];
                  // Chuyển DateTime thành chuỗi hiển thị nếu muốn (tùy bạn format)
                  final formattedTime =
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year}  ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tx.message, style: smallTextStyle),
                    subtitle: Text(formattedTime, style: xSmallTextStyle),
                    trailing: RichText(
                      text: TextSpan(
                        text: _formatCurrency(tx.amount) + ' ',
                        style: mediumTextStyle.copyWith(color: redColor),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.top,
                            child: Transform.translate(
                              offset: Offset(0, -2),
                              child: Text(
                                'vnđ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: redColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Ví dụ hàm format số tiền (voî̃n tệ) cho đẹp: 1,234,000
 String _formatCurrency(double amount) {
  // Chuyển thành chuỗi với 2 chữ số thập phân
  final raw = amount.toStringAsFixed(2); // Ví dụ: "1234.00", "1234.50", "1234.56"
  final parts = raw.split('.');
  String integerPart = parts[0];           // Ví dụ: "1234"
  String decimalPart = parts[1];           // Ví dụ: "00", "50", "56"

  // Thêm dấu phẩy vào phần nguyên
  final buffer = StringBuffer();
  for (int i = 0; i < integerPart.length; i++) {
    final posFromRight = integerPart.length - i;
    buffer.write(integerPart[i]);
    if (posFromRight > 1 && posFromRight % 3 == 1) {
      buffer.write(',');
    }
  }
  String formattedInteger = buffer.toString(); // Ví dụ: "1,234"

  // Nếu phần thập phân là "00", bỏ luôn
  if (decimalPart == '00') {
    return formattedInteger;
  }

  // Ngược lại, giữ lại phần thập phân
  return '$formattedInteger.$decimalPart';
}

}
