import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'tranferqr.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result; // Lưu kết quả quét lần đầu (nếu muốn hiển thị tạm)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Xử lý khi app vào background hoặc trở lại foreground
    if (controller != null) {
      if (state == AppLifecycleState.paused) {
        controller?.pauseCamera();
      } else if (state == AppLifecycleState.resumed) {
        controller?.resumeCamera();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void reassemble() {
    super.reassemble();
    // Khi hot reload, cần pause/resume camera để tránh lỗi
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        actions: [
          // Nút bật/tắt đèn flash
          IconButton(
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Icon(Icons.flash_on);
                } else {
                  return const Icon(Icons.flash_off);
                }
              },
            ),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          // Nút đổi camera
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Phần khung camera chiếm 5/7 chiều cao
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                // Kích thước vùng quét bằng 70% chiều rộng màn hình
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          // Phần hiển thị tạm kết quả và nút quét lại (nếu cần)
          Expanded(
            flex: 2,
            child: Center(
              child: result != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nội dung: ${result!.code}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Cho phép quét lại
                            setState(() {
                              result = null;
                            });
                            controller?.resumeCamera();
                          },
                          child: const Text('Quét lại'),
                        ),
                      ],
                    )
                  : const Text(
                      'Đưa mã QR vào khung để quét',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;

    controller!.scannedDataStream.listen((scanData) async {
      final raw = scanData.code;
      // Nếu chưa có kết quả trước đó và raw không null
      if (result == null && raw != null) {
        // Kiểm tra chuỗi có chứa dấu "|" hay không
        if (raw.contains('|')) {
          final parts = raw.split('|');
          if (parts.length >= 2) {
            final id = parts[0];
            final info = parts.sublist(1).join('|');
            // Dừng camera ngay lập tức
            await controller?.pauseCamera();
            setState(() {
              result = scanData;
            });
            // Delay một chút để camera thực sự pause rồi mới chuyển trang
            await Future.delayed(const Duration(milliseconds: 200));
            if (!mounted) return;
            // Điều hướng: thay thế QRScanPage bằng DetailPage
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TransferQrPage(initialAccount: id, initialName: info),
              ),
            );
            return;
          }
        }
        // Nếu không có dấu "|" hoặc tách không đúng format, chỉ show kết quả bình thường
        await controller?.pauseCamera();
        setState(() {
          result = scanData;
        });
      }
    });
  }
}
