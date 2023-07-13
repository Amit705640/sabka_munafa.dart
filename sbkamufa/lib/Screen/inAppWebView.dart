import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sbkamufa/Notification.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';


class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}
class _InAppWebViewPageState extends State<InAppWebViewPage> {
  NotificationServices  notification = NotificationServices();

  late InAppWebViewController _webViewController;
  late InAppWebViewController _webViewPopupController;
  // final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  String _referrerDetails = '';


  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();
  bool pullToRefreshEnabled = true;
  bool isOnline = true;

  void checkOnline() async {
    isOnline = await InternetConnectionChecker().hasConnection;
  }


  @override
  void initState() {
    super.initState();
    initReferrerDetails();

    checkOnline();
    pullToRefreshController = PullToRefreshController(    // pull to refresh indicator to refresh initState
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload().timeout(Duration(seconds: 3));
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );

    // Notification show
    notification.requestNotification();
    // firebase token send  to Api
    notification.getDeviceToken().then((Token) {
    var token =  notification.SendPushNotifications(Token);
    //  print('device token${token}');
    });
  }
  // PlayStore generate referral code
  Future<void> initReferrerDetails() async {
    String referrerDetailsString;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

      referrerDetailsString = referrerDetails.toString();
    } catch (e) {
      referrerDetailsString = 'Failed to get referrer details: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _referrerDetails = referrerDetailsString;
    });
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var consolemsg ='';
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black, // Color for Android
        statusBarBrightness:
        Brightness.dark // Dark == white status bar -- for IOS.
    ));
    return  isOnline ? // Check internet connection for device
    WillPopScope(
      onWillPop: () async{      // device back button
        if(_webViewController !=null && await _webViewController!.canGoBack() ){
          // print("can go back");
          _webViewController!.goBack();
          return false;
        }
        showDialog(context: context,
            // barrierDismissible: false,
            builder: (context){
              return AlertDialog(
                title: Text('Confirmation',style: TextStyle(color: Colors.black),),
                content: Text('Do you want to exit app?'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: (){
                        Navigator.of(context).pop(false);
                      }, child: Text('No')),
                      TextButton(onPressed: () async {
                        exit(0);
                      }, child: Text('Yes')),
                    ],
                  ),
                ],
              );
            }).then((exit) {
          if(exit == null)return;
        });
        //  print("unable to go back");
        return true;
      },
      child : GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body:
          SafeArea(
            child: Container(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse('http://sabkamunafa.havflyinvitation.com/')),

                // console message get
                onConsoleMessage: (controller, request)async{
                 // print('sdafja;klw ${request.message}');
                  consolemsg = request.message;
                  final String ab = consolemsg;
                  List<String> parts = ab.split(':');
                  String firstPart = parts[0];
                  String secondPart = parts[1];
                  // print(firstPart);
                  // print('sadaf${secondPart}');
                  // print('fdsaf${_referrerDetails}');
                  if(firstPart == 'cc6796d6ab1b46826daf987307264d8d'){
                  var data =  API().Post(secondPart, _referrerDetails, consolemsg);
                    print(data);
                  }
                },

                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        disableContextMenu: true,
                        // debuggingEnabled: true,
                        // set this to true if you are using window.open to open a new window with JavaScript
                        javaScriptCanOpenWindowsAutomatically: true,
                    ),

                    android: AndroidInAppWebViewOptions(
                      // on Android you need to set supportMultipleWindows to true,
                      // otherwise the onCreateWindow event won't be called
                      supportMultipleWindows: true,
                      disableDefaultErrorPage: true,
                      useShouldInterceptRequest: true,
                    ),
                  ios: IOSInAppWebViewOptions(
                    allowsAirPlayForMediaPlayback: true,
                  )
                ),
                pullToRefreshController: pullToRefreshController,
                onLoadStart: (controller, url ){
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onCreateWindow: (controller, createWindowRequest) async {
                  print("onCreateWindow");
                  showDialog(
                    context: context,
                    builder: (context) {
                      var height = MediaQuery.of(context).size.height;
                      var width = MediaQuery.of(context).size.width;
                      return
                        // icon: Icon(Icons.cancel,color: Colors.red,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Positioned(
                                  top: 0.0,
                                  right: 0.0,
                                  child: FloatingActionButton.small(
                                    child: FaIcon(FontAwesomeIcons.xmark,color: Colors.white,),
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: width ,
                                  height: height / 2,
                                  child: InAppWebView(
                                    // Setting the windowId property is important here!
                                    windowId: createWindowRequest.windowId,
                                    initialOptions: InAppWebViewGroupOptions(
                                      android: AndroidInAppWebViewOptions(
                                        allowContentAccess: true,
                                        allowFileAccess: true,
                                    ),
                                      crossPlatform: InAppWebViewOptions(
                                        // debuggingEnabled: true,
                                      ),
                                    ),
                                    onWebViewCreated: (InAppWebViewController controller) {
                                      _webViewPopupController = controller;
                                    },
                                    onLoadStart: ( controller,  url) {
                                      print("onLoadStart popup $url");
                                    },
                                    onLoadStop: ( controller, url) {
                                      print("onLoadStop popup $url");
                                    },
                                  ),
                                ),
                              ),
                              progress < 1.0
                                  ? LinearProgressIndicator(value:  progress)
                                  : Container(),
                            ],
                          ),
                        );
                    },
                  );
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    )
        : Center(
          child:  GestureDetector(   //
             child: Container(
                 child: Image.asset('assert/No internet.png',fit: BoxFit.cover,height: MediaQuery.of(context).size.height,)),
              onTap: (){
              setState(() {
            checkOnline();
           });
          },),
      );
  }
}


