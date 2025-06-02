import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import '/components/c_elevated_button.dart';
import '/utils/constants.dart';
import '../../../utils/routes.dart';
import 'package:percent_indicator/percent_indicator.dart';

class RegisterFingerprintUnlockPage extends StatefulWidget {
  const RegisterFingerprintUnlockPage({super.key});

  @override
  State<RegisterFingerprintUnlockPage> createState() =>
      _RegisterFingerprintUnlockPageState();
}

class _RegisterFingerprintUnlockPageState
    extends State<RegisterFingerprintUnlockPage> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool success = false;
  bool failed = false;
  bool noBiometric = false;

  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAuthenticate();
    });
  }

  Future<void> _checkAndAuthenticate() async {
    bool canCheckBiometrics = false;
    bool isDeviceSupported = false;
    List<BiometricType> availableBiometrics = [];

    try {
      
      isDeviceSupported = await _auth.isDeviceSupported();
     
      canCheckBiometrics = await _auth.canCheckBiometrics;
     
      availableBiometrics = await _auth.getAvailableBiometrics();
    } catch (e) {
      isDeviceSupported = false;
      canCheckBiometrics = false;
      availableBiometrics = [];
    }


    // print(">>> isDeviceSupported: $isDeviceSupported");
    // print(">>> canCheckBiometrics: $canCheckBiometrics");
    // print(">>> availableBiometrics: $availableBiometrics");

    if (!isDeviceSupported || !canCheckBiometrics) {
      
      setState(() {
        noBiometric = true;
        success = false;
        failed = false;
      });
      return;
    }

    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await _auth.authenticate(
        localizedReason:
            'Vui lòng xác thực vân tay/Face ID để bảo mật tài khoản',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      // print(">>> BiometricPrompt returned: $authenticated");
    } catch (e) {
      authenticated = false;
      // print(">>> Error when calling authenticate(): $e");
    }

    if (!mounted) return;

    setState(() {
      if (authenticated) {
        success = true;
        failed = false;
        noBiometric = false;
      } else {
        success = false;
        failed = true;
        noBiometric = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: REdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        children: [
      
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20.r,
                  color: primaryColor,
                ),
              ),
              Text(
                'Step 2 of 2',
                style: smallTextStyle,
              ),
            ],
          ),

          SizedBox(height: 136.h),

          Column(
            children: [
              Text(
                'Bảo mật sinh trắc học',
                style: largeTextStyle,
              ),
              SizedBox(height: 8.h),
              Text(
                'Để bảo mật nâng cao hơn, hãy đăng ký bảo mật sinh trắc học',
                style: xSmallTextStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 47.h),

              if (noBiometric)
          
                Image.asset(
                  'assets/images/icons8-fingerprint-scan-100.png',
                  width: 90.r,
                  height: 90.r,
                )
              else if (success)
              
                Image.asset(
                  'assets/images/icons8-fingerprint-accepted-100.png',
                  width: 90.r,
                  height: 90.r,
                )
              else if (failed)
                // Nếu xác thực thất bại
                Image.asset(
                  'assets/images/icons8-fingerprint-error-100.png',
                  width: 90.r,
                  height: 90.r,
                )
              else
               
                CircularPercentIndicator(
                  radius: 90.r,
                  lineWidth: 4.w,
                  percent: 0.5, 
                  reverse: true,
                  backgroundColor: const Color(0xFFFFF9EF),
                  center: SvgPicture.asset(
                    'assets/svg/fingerprint_icon.svg',
                    width: 60.r,
                    height: 60.r,
                  ),
                  progressColor: const Color(0xFFFCC97C),
                ),

              SizedBox(height: 40.h),

              if (noBiometric)
                Text(
                  'Thiết bị không hỗ trợ hoặc chưa đăng ký sinh trắc học.\nBạn có thể tiếp tục mà không sử dụng tính năng này.',
                  style: xSmallTextStyle,
                  textAlign: TextAlign.center,
                )
              else if (success)
                Text(
                  'Xác thực thành công, bạn có thể tiếp tục',
                  style: xSmallTextStyle,
                  textAlign: TextAlign.center,
                )
              else if (failed)
                Text(
                  'Xác thực thất bại, vui lòng xác thực lại!',
                  style: xSmallTextStyle,
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Sử dụng sinh trắc học của bạn để đăng ký dữ liệu',
                  style: xSmallTextStyle,
                  textAlign: TextAlign.center,
                ),

              SizedBox(height: 143.h),

              SizedBox(
                width: double.infinity,
                child: CElevatedButton(
      
                  child: Text(
                    noBiometric
                        ? 'Tiếp tục'
                        : (success ? 'Tiếp tục' : 'Thử lại'),
                  ),
                  onPressed: () {
                    if (noBiometric || success) {
                  
                      Navigator.of(context).pushNamed(
                        RouteGenerator.registerSuccessPage,
                      );
                    } else {
                  
                      setState(() {
                        failed = false;
                        success = false;
                      });
                      _authenticate();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
