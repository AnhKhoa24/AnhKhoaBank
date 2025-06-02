import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  
  static Future<String?> getFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      return token;
    } catch (e) {
      debugPrint('[DeviceService] Lỗi khi lấy FCM token: $e');
      return null;
    }
  }

  static Future<String> getDeviceInfoString() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
       
        final brand = androidInfo.brand;
        final device = androidInfo.device;
        final model = androidInfo.model;
        final manufacturer = androidInfo.manufacturer;
        final product = androidInfo.product;
    
        return [
          if (brand.isNotEmpty) brand,
          if (device.isNotEmpty) device,
          if (model.isNotEmpty) model,
          if (manufacturer.isNotEmpty) manufacturer,
          if (product.isNotEmpty) product,
        ].join('_');
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        final name = iosInfo.name;
        final model = iosInfo.model;
        final systemName = iosInfo.systemName;
        final systemVersion = iosInfo.systemVersion;
        return [
          if (name.isNotEmpty) name,
          if (model.isNotEmpty) model,
          if (systemName.isNotEmpty) systemName,
          if (systemVersion.isNotEmpty) systemVersion,
        ].join('_');
      } else {
        return 'platform: unknown';
      }
    } catch (e) {
      debugPrint('[DeviceService] Lỗi khi lấy thông tin thiết bị: $e');
      return 'platform: unknown';
    }
  }
}
