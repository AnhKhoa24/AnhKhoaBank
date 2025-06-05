import 'package:banking/services/get_check_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // để format DateTime
import '../../../utils/constants.dart'; // Đảm bảo đúng đường dẫn tới BankingService

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<GetMessages> _futureNotifications;
  final BankingService _bankingService = BankingService();

  // Set lưu các index đang được mở rộng
  final Set<int> _expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi widget được khởi tạo
    _futureNotifications = _bankingService.getNotification();
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
        title: Text(
          'Thông báo',
          style: mediumTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryColor,
            size: 20.r,
          ),
        ),
      ),
      body: FutureBuilder<GetMessages>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Đang chờ API trả về
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Nếu có lỗi
            return Center(
              child: Text(
                'Có lỗi xảy ra: ${snapshot.error}',
                style: xSmallTextStyle,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.msgs.isEmpty) {
            // Nếu không có data hoặc danh sách rỗng
            return Center(
              child: Text(
                'Không có thông báo nào.',
                style: xSmallTextStyle,
              ),
            );
          }

          // Lấy danh sách msgs từ API
          final List<Messages> msgList = snapshot.data!.msgs;

          return ListView.separated(
            separatorBuilder: (context, index) => listViewSeparator,
            itemCount: msgList.length,
            shrinkWrap: true,
            padding: REdgeInsets.all(24),
            itemBuilder: (context, index) {
              final msg = msgList[index];
              final formattedDate = DateFormat('MMMM d, yyyy').format(msg.createdAt);
              final isExpanded = _expandedIndexes.contains(index);

              return Slidable(
                key: ValueKey(msg.createdAt.millisecondsSinceEpoch),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      spacing: 10,
                      borderRadius: BorderRadius.all(Radius.circular(6.r)),
                      onPressed: (_) {
                        // TODO: xử lý xóa item nếu cần, ví dụ gọi API xóa hoặc cập nhật trạng thái
                      },
                      backgroundColor: const Color(0xFFCF3100),
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_outlined,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedIndexes.remove(index);
                      } else {
                        _expandedIndexes.add(index);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      color: Colors.white,
                    ),
                    padding: REdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: “Nguồn” và ngày
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hệ thống',
                              style: xXSmallTextStyle,
                            ),
                            Text(
                              formattedDate,
                              style: xXSmallTextStyle,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Tiêu đề (nếu API có trường title, bạn có thể thay msg.content thành msg.title)
                        Text(
                          'Thông báo tài khoản',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF160D07),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Nội dung thông báo: nếu isExpanded thì hiển thị full, không giới hạn số dòng
                        Text(
                          msg.content,
                          style: xSmallTextStyle,
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),

                        // Nếu đang ở trạng thái mở rộng, có thể hiển thị chỉ dẫn "Chạm để thu gọn"
                        if (isExpanded) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Chạm để thu gọn',
                            style: xSmallTextStyle.copyWith(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
