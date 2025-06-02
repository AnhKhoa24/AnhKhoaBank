import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("📩 [Background] Message ID: ${message.messageId}");
}

class NotificationService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotification();

    await _requestNotificationPermission();

    _setupFirebaseHandlers();

    await _getFCMToken();
  }

  static Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("[Permission] Đã được cấp.");
    } else {
      print("[Permission] Bị từ chối.");
    }
  }

  static Future<void> _initLocalNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  static void _setupFirebaseHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[Foreground] ${message.notification?.title}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[Opened from background] ${message.data}');
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('[Opened from terminated state] ${message.data}');
      }
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Thông báo Firebase',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title ?? 'Không có tiêu đề',
      message.notification?.body ?? 'Không có nội dung',
      notificationDetails,
    );
  }

  static Future<String?> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print("🔑 [FCM Token] $token");
      return token;
    } on FirebaseException catch (e) {
      print("[FCM Error] code=${e.code}, message=${e.message}");
    } catch (e) {
      print("[FCM Unknown Error] $e");
    }
    return null;
  }
}
