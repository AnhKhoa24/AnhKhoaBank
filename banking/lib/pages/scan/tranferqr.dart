import 'package:banking/services/biometric_popup.dart';
import 'package:banking/services/get_check_account.dart';
import 'package:banking/services/banking_api.dart';
import 'package:banking/pages/dashboard/transfer/transfer_successful_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/components/c_text_form_field.dart';
import '/utils/constants.dart';
import '/widgets/balance_card_loader.dart';

class TransferQrPage extends StatefulWidget {
  // Cho phép truyền sẵn số tài khoản + tên tài khoản khi push từ QRScanPage
  final String? initialAccount;
  final String? initialName;

  const TransferQrPage({Key? key, this.initialAccount, this.initialName})
    : super(key: key);

  @override
  State<TransferQrPage> createState() => _TransferQrPageState();
}

class _TransferQrPageState extends State<TransferQrPage> {
  String _accountRaw = '';
  late TextEditingController
  _accountController; // controller cho ô nhập số tài khoản
  late TextEditingController _messageController;
  late TextEditingController _amountController;

  bool _isAccountLoading = false;
  String? _accountFullName;
  String? _accountError;

  bool _isTransferLoading = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller cho ô nhập số tài khoản
    _accountController = TextEditingController();

    // Nếu có initialAccount (được gửi từ QRScanPage), điền sẵn vào ô
    if (widget.initialAccount != null) {
      _accountRaw = widget.initialAccount!;
      _accountController.text = widget.initialAccount!;
      // Nếu đồng thời có initialName, gán luôn vào biến hiển thị tên
      if (widget.initialName != null) {
        _accountFullName = widget.initialName;
      } else {
        // Nếu chỉ có số tài khoản trước, bạn có thể gọi API checkAccount tương tự hàm _onAccountChanged
        _fetchAccountName(widget.initialAccount!);
      }
    }

    _amountController = TextEditingController()..addListener(_onAmountChanged);
    _messageController = TextEditingController(text: 'Chuyển tiền');
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _messageController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  // Gọi API checkAccount khi chỉ có số tài khoản, muốn lấy tên
  Future<void> _fetchAccountName(String accountNumber) async {
    setState(() {
      _isAccountLoading = true;
      _accountError = null;
      _accountFullName = null;
    });
    try {
      final bankingService = BankingService();
      final response = await bankingService.checkAccount(
        accountNumber: accountNumber,
      );
      if (response.success) {
        setState(() {
          _accountFullName = response.fullname;
        });
      } else {
        setState(() {
          _accountError = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _accountError = e.toString();
      });
    } finally {
      setState(() {
        _isAccountLoading = false;
      });
    }
  }

  Future<void> _onAccountChanged(String newValue) async {
    final rawDigits = newValue.replaceAll(RegExp(r'[^0-9]'), '');
    _accountRaw = rawDigits;

    if (_accountRaw.length < 10) {
      if (_accountFullName != null || _accountError != null) {
        setState(() {
          _accountFullName = null;
          _accountError = null;
        });
      }
      return;
    }

    setState(() {
      _isAccountLoading = true;
      _accountFullName = null;
      _accountError = null;
    });

    try {
      final bankingService = BankingService();
      final response = await bankingService.checkAccount(
        accountNumber: _accountRaw,
      );

      if (response.success) {
        setState(() {
          _accountFullName = response.fullname;
          _accountError = null;
        });
      } else {
        setState(() {
          _accountFullName = null;
          _accountError = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _accountFullName = null;
        _accountError = e.toString();
      });
    } finally {
      setState(() {
        _isAccountLoading = false;
      });
    }
  }

  void _onAmountChanged() {
    final rawText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (rawText.isEmpty) {
      _amountController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      setState(() {});
      return;
    }

    final parsed = int.parse(rawText);
    final formatted = NumberFormat.decimalPattern().format(parsed);

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  double getTien() {
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return rawAmount.isEmpty ? 0.0 : double.parse(rawAmount);
  }

  Future<void> _authenticateAndTransfer() async {
    final BiometricService _biometricService = BiometricService();
    final bool isAuth = await _biometricService.authenticate();
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác thực sinh trắc học không thành công'),
        ),
      );
      return;
    }
    if (_isTransferLoading) return;

    _handleTransfer();
  }

  Future<void> _handleTransfer() async {
    final rawAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final double amountValue =
        rawAmount.isEmpty ? 0.0 : double.parse(rawAmount);
    final String messageValue = _messageController.text;

    if (_accountRaw.isEmpty || _accountRaw.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tài khoản hợp lệ')),
      );
      return;
    }
    if (amountValue <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
      return;
    }

    setState(() {
      _isTransferLoading = true;
    });

    try {
      final service = TranferService();
      final resp = await service.transfer(
        accountNumber: _accountRaw,
        amount: amountValue,
        message: messageValue,
      );

      if (resp.success) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => TransferSuccessfulPage(
                  recipientName: _accountFullName!,
                  recipientAccount: _accountRaw,
                  amount: amountValue,
                  timestamp: DateTime.now(),
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Thất bại: ${resp.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isTransferLoading = false;
        });
      }
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
        padding: REdgeInsets.all(24),
        shrinkWrap: true,
        children: [
          Text('Ngân hàng', style: mediumTextStyle),
          SizedBox(height: 16.h),
          Container(
            padding: REdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F6),
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: ListTile(
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
          SizedBox(height: 12.h),

          CTextFormField(
            textControllor: _accountController,
            hintText: '1234567890',
            onChanged: _onAccountChanged,
          ),

          SizedBox(height: 8.h),

          if (_isAccountLoading)
            Row(
              children: [
                SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Đang kiểm tra tài khoản...',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          else if (_accountFullName != null)
            Text(
              '   $_accountFullName',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade700,
              ),
            )
          else if (_accountError != null)
            Text(
              '$_accountError',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.red.shade600,
              ),
            ),

          SizedBox(height: 16.h),

          // Hiển thị Balance
          Text('Balance', style: mediumTextStyle),
          SizedBox(height: 12.h),
          const BalanceCardLoader(),
          SizedBox(height: 24.h),

          // Trường “Số tiền”
          Text('Số tiền', style: mediumTextStyle),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F6),
              borderRadius: BorderRadius.all(Radius.circular(6.r)),
            ),
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: heading2.copyWith(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: REdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                suffixText: 'vnđ',
                suffixStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),

          // Trường “Lời nhắn”
          Text('Lời nhắn', style: mediumTextStyle),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _messageController,
            minLines: 2,
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              contentPadding: REdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            child:
                _isTransferLoading
                    ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Chuyển tiền'),
            onPressed:
                (_accountFullName != null &&
                        !_isTransferLoading &&
                        getTien() > 1000)
                    ? () {
                      _authenticateAndTransfer();
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
