import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/getdash_board_user.dart';
import '../services/format_info_account.dart';
import 'balance_card.dart';

class BalanceCardLoader extends StatefulWidget {
  const BalanceCardLoader({Key? key}) : super(key: key);

  @override
  _BalanceCardLoaderState createState() => _BalanceCardLoaderState();
}

class _BalanceCardLoaderState extends State<BalanceCardLoader> {
  bool _isLoading = true;
  bool _hasError = false;
  String _balanceText = '';
  String _accountText = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await UserService.fetchUserProfile();
      if (profile == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      final formattedBalance = FormatUtils.formatBalance(profile.balance);
      final accountNum = FormatUtils.maskAccountNumber(profile.accountNumber);

      setState(() {
        _balanceText = formattedBalance;
        _accountText = accountNum;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_hasError) {
      return _buildErrorCard();
    }

    return BalanceCard(
      balanceText: _balanceText,
      accountText: _accountText,
    );
  }

  Widget _buildLoadingCard() {
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: 3327.w,
              height: 88.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 24.h,
              width: 24.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return SizedBox(
      height: 95.h,
      width: double.infinity,
      child: Center(
        child: Text(
          'Không thể tải thông tin',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
