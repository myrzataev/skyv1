import 'dart:convert';
import 'package:Skynet/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:Skynet/views/start.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';




Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
  }

  runApp(MyApp());
}
@override
void initState() {
  requestPermission();
  setupFirebaseMessagingListeners();
}



void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');


}

void setupFirebaseMessagingListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground messages
    // ... (same as previous example)
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle notification tap
    // ... (same as previous example)
  });
}

class MyApp extends StatelessWidget {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {


    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'skynet',

        supportedLocales: [
          const Locale('en', ''), // English
          const Locale('es', ''), // Spanish
          // Add other locales your app supports
        ],
        theme:  ThemeData.dark(),

        home: FutureBuilder(

          future: _tryAutoLogin(),
          builder: (context, snapshot) {
            // Check if the future is complete
            if (snapshot.connectionState == ConnectionState.done) {
              // If we have data, it means auto login was successful
              if (snapshot.hasData && snapshot.data ==true) {
                return Start();
              } else {
                return LoginScreen();
                // return Start();
              }
            }
            // While we're waiting, show a progress indicator
            return Scaffold(
              backgroundColor: Colors.white, // Установите белый цвет фона

              body: Center(

                child: Image.asset(
                  'images/assets/loader.png', // Путь к вашей картинке в assets
                  width: 200, // Установите размеры картинки по вашему усмотрению
                  height: 200,
                ),
              ),
            );
          },
        ),
      );

  }
  final storage = FlutterSecureStorage();


  Future<bool> _tryAutoLogin() async {
    try {

      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');
      String? firebase_token = await FirebaseMessaging.instance.getToken();
      print(firebase_token);
      await storage.write(key: 'firebase_token', value: firebase_token);
      final firebase_tokens = await storage.read(key: 'firebase_token');

      if (username != null && password != null) {
        final Uri uri = Uri.parse('http://91.210.169.237:8001/login/');
        final Map<String, String> headers = {'Content-Type': 'application/x-www-form-urlencoded'};
        final Map<String, String> body = {'ls_abonent': username, 'phone_number': password, 'firebase_token':'$firebase_tokens', 'version': "mobile"};
   try {
          final response = await http.post(uri, headers: headers, body: body);
          if (response.statusCode == 200) {


            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final storage = FlutterSecureStorage();
            final version = packageInfo.version;


            await storage.write(key: 'version', value: version);
            final data = json.decode(response.body);
            await storage.write(key: 'token', value: data['token'].toString());
            final password = await storage.read(key: 'token');
            await storage.write(key: 'password', value: password);


          }
        } catch (e) {
          // Handle any errors that occur during the request
          print('Error occurred: $e');
        }

        return true;
      }
    } catch (e) {
      print('Error during auto login: $e');
    }
    return false;
  }
}
