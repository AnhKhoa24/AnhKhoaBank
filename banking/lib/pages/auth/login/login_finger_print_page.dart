import 'dart:typed_data';
import 'package:banking/services/check_token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QrCodeWidget extends StatefulWidget {
  const QrCodeWidget({Key? key}) : super(key: key);

  @override
  _QrCodeWidgetState createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
  }

  Future<void> _fetchQrCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService().getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = 'Không tìm thấy token. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      final uri = Uri.parse('https://anhkhoa.tryasp.net/api/Notification/qrcode');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Lỗi tải QR (code = ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenSize = MediaQuery.of(context).size;
    // Cho Container phủ hết màn hình (hoặc bạn có thể congiào padding SafeArea)
    final cardWidth = screenSize.width;
    final cardHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(170, 9, 86, 158),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _buildContent(cardWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double maxCardWidth) {
    // Đặt chiều cao cố định cho phần loading/error để layout không nhảy
    const double boxHeight = 300;

    if (_isLoading) {
      return SizedBox(
        height: boxHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: boxHeight,
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      // Tính kích thước khung QR bằng 60% cardWidth (hoặc chỉnh tùy ý)
      final qrSize = maxCardWidth * 0.6;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center, // <-- Căn giữa theo chiều dọc
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Quét mã QR bên dưới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white, // chữ trắng cho nổi trên nền xanh
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchQrCode,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Tải lại mã QR'),
            style: ElevatedButton.styleFrom(
              // primary: Colors.white, // nền nút trắng
              // onPrimary: const Color.fromARGB(170, 9, 86, 158), // màu icon + text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }

    // Trường hợp “vô lý” (không loading, không lỗi, không có ảnh)
    return const SizedBox(height: boxHeight);
  }
}
