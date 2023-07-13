import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';

 String baseurl = 'http://sabkamunafa.havflyinvitation.com/';
class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted notification permission');
    } else
    if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('user perminison notification permission');
    } else {
      AppSettings.openNotificationSettings();
      print('user denided notification permission');
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }


// Send push notification api
  Future<void> SendPushNotifications(String userToken) async {
try {
 // final postUrl = 'http://sabkamunafa.havflyinvitation.com/api/devicetoken/add';
  final data = {
    "deviceToken": userToken,
  };

  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    // HttpHeaders
    //     .authorizationHeader: 'AAAAm_hG2Vc:APA91bHcP2_r4k_HJYN5c9pm1NlW2EMIA4lhsrsCaxo-Ladizo0doMy0ACCS1NxUrz_bytEDXekom-xs-kX_6i0cph-gvTygbKIiLRXgvF7GOcoG8egVPvpFCxSkV4vczDwQ1EDHSNeZ'
  };
  final response = await http.post(Uri.parse(baseurl +'api/devicetoken/add'),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers
  );
  if (response.statusCode == 200) {
    // on success do sth
    print('test ok push Api');
  } else {
    print('API error');
    // on failure do sth
  }
}catch(e){
  log('\n sendPushNotificationE: $e');
}
  }
}
class API{
 // String baseUrl = 'http://sabkamunafa.havflyinvitation.com/';

  // Post api
  Future Post( String id, String url, String mdFCode) async {
    final data = {
      "id" : id,
      "mdFCode": mdFCode,
      "url": url
    };


    final response = await http.post(
      Uri.parse( baseurl + 'api/add/device' , ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',

      },
      body: jsonEncode(
        data
      ),
    );

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON.
      var apiResponse = jsonDecode(response.body);
      if(apiResponse['status'] == 1) {
        return apiResponse;
      } else {
        return 0;
        // return show dialog box
      }
    } else {
      throw Exception('Failed to create album.');
    }
  }
}