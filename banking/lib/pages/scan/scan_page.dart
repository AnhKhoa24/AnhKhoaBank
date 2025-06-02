import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../utils/constants.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedText;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF656565),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Scan',
          style: mediumTextStyle.copyWith(color: whiteColor),
        ),
        backgroundColor: const Color(0xFF656565),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: whiteColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    setState(() {
                      scannedText = code;
                    });
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: REdgeInsets.all(20),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      cameraController.toggleTorch();
                    },
                    child: SvgPicture.asset('assets/svg/flash_icon.svg'),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/shutter_icon.svg'),
                      SizedBox(width: 20.w),
                      SvgPicture.asset('assets/svg/recent_icon.svg'),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  if (scannedText != null)
                    Text(
                      'Scanned: $scannedText',
                      style: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
