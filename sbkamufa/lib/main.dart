import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Screen/splash_screen.dart';
import 'package:app_settings/app_settings.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xcf03397c), // Color for Android
      statusBarBrightness:
      Brightness.dark // Dark == white status bar -- for IOS.
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 await Permission.camera.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primaryColor: Colors.black,
            primaryColorLight: Colors.black,
          ),
          home:  SplashScreen(),
          debugShowCheckedModeBanner: false,
    );
  }
}
