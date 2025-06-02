// lib/services/biometric_service.dart

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Kiểm tra và hiển thị dialog hệ thống để xác thực sinh trắc học.
  /// Trả về `true` nếu xác thực thành công, `false` nếu thất bại hoặc không hỗ trợ.
  Future<bool> authenticate() async {
    try {
      // 1. Kiểm tra thiết bị có hỗ trợ biometrics không?
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        // Không hỗ trợ vân tay/face
        return false;
      }

      // 2. Lấy danh sách các loại sinh trắc khả dụng (fingerprint, face, v.v.)
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        // Thiết bị hỗ trợ nhưng người dùng chưa đăng ký bất kỳ sinh trắc nào
        return false;
      }

      // 3. Yêu cầu người dùng xác thực
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Vui lòng xác thực sinh trắc học để tiếp tục',
        options: const AuthenticationOptions(
          stickyAuth: true,      // Giữ trạng thái xác thực khi app chuyển background
          biometricOnly: true,   // Chỉ cho phép dùng vân tay/face (không yêu cầu passcode)
        ),
      );

      return didAuthenticate;
    } catch (e) {
      // Nếu có exception (ví dụ thư viện bị lỗi), trả về false
      return false;
    }
  }
}
