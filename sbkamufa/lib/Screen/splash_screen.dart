import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sbkamufa/Screen/inAppWebView.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> InAppWebViewPage() ));
    });
  }
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //     statusBarColor: Colors, // Color for Android
    //     statusBarBrightness:
    //     Brightness.dark // Dark == white status bar -- for IOS.
    // ));
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assert/splash image.png', fit: BoxFit.cover,height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          )],),
    );
  }
}