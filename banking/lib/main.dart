import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/providers/date_provider.dart';
import '/utils/constants.dart';
import '/utils/pallete.dart';
import '/utils/routes.dart';
import 'package:provider/provider.dart';
import 'providers/confirm_password_provider.dart';
import 'providers/password_provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'services/nofiface_services.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await NotificationService.initialize();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await FaceCamera.initialize(); 
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, 
    statusBarColor: Colors.transparent, 
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => PasswordProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ConfirmPasswordProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => DateProvider(),
          ),
        ],
        child: MaterialApp(
          title: 'Wallet App',
          theme: ThemeData(
            primarySwatch: Palette.primaryPaletteColor,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: primaryColor,
              selectionColor: primaryColor,
              selectionHandleColor: primaryColor,
            ),
          ),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: RouteGenerator.splashPage,
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );
  }
}
