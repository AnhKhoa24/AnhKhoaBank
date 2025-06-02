import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../components/c_elevated_button.dart';
import '../../../utils/constants.dart';
import '../../../utils/routes.dart';

class CaptureIdentityCardPage extends StatefulWidget {
  const CaptureIdentityCardPage({super.key});

  @override
  State<CaptureIdentityCardPage> createState() => _CaptureIdentityCardPageState();
}

class _CaptureIdentityCardPageState extends State<CaptureIdentityCardPage> {
  late final FaceCameraController _controller;
  File? _capturedImage;
  bool success = false;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        if (image != null) {
          setState(() {
            _capturedImage = image;
            success = true;
            failed = false;
          });
        } else {
          setState(() {
            success = false;
            failed = true;
          });
        }
        Navigator.of(context).pop(); // đóng camera sau khi chụp
      },
      onFaceDetected: (Face? face) {
        // Replace 'wellPositioned' with a valid property or implement your own logic
        if (face == null /* || !face.wellPositioned */) {
          setState(() {
            failed = true;
            success = false;
          });
        } else {
          setState(() {
            success = true;
            failed = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: SafeArea(
            child: SmartFaceCamera(
              controller: _controller,
              messageBuilder: (context, face) {
                if (face == null) {
                  return _message('Place your face in the camera');
                } else if (!face.wellPositioned) {
                  return _message('Center your face in the square');
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
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
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back_ios, size: 20.r, color: primaryColor),
              ),
              Text('Step 2 of 4', style: smallTextStyle),
            ],
          ),
          SizedBox(height: 136.h),
          Center(
            child: Column(
              children: [
                Text(
                  'Take a Picture of your\nIdentity card',
                  style: largeTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Take a full picture of your ID card',
                  style: xSmallTextStyle,
                ),
                SizedBox(height: 52.h),
                SizedBox(
                  height: 206.h,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        child: SvgPicture.asset('assets/svg/scan_image.svg'),
                      ),
                      Positioned(
                        top: 88.h,
                        bottom: 88.h,
                        left: 142.w,
                        right: 142.w,
                        child: success
                            ? SvgPicture.asset('assets/svg/success_icon.svg')
                            : failed
                                ? SvgPicture.asset('assets/svg/failed_icon.svg')
                                : const SizedBox(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                success
                    ? Text(
                        'Registration is successful, you can proceed\nto the next step',
                        style: xSmallTextStyle,
                        textAlign: TextAlign.center,
                      )
                    : failed
                        ? Text(
                            'Registration failed, try again or clean your camera',
                            style: xSmallTextStyle,
                            textAlign: TextAlign.center,
                          )
                        : const Text(''),
                SizedBox(height: 120.h),
                SizedBox(
                  width: double.infinity,
                  child: CElevatedButton(
                    child: Text(success
                        ? 'Continue'
                        : failed
                            ? 'Retry'
                            : 'Take Picture'),
                    onPressed: () {
                      _openCamera();
                      if (success) {
                        Navigator.of(context).pushNamed(
                          RouteGenerator.registerFingerprintUnlockPage,
                        );
                      }
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

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}