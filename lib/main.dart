import 'package:chat_app/colors.dart';
import 'package:chat_app/locator.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/login_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() {
  setupLocator();
  runApp(ChatApp());
}

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  bool _isUserLoggedIn = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final DatabaseHelper dbHelper = DatabaseHelper();
  Widget initialRoute = LoginPage();

  String _getToken() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
      ChatPreferences.saveFirebaseToken(token);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isUserLoggedIn = false;
    getUserLoggedIn();
    _getToken();
    _configureFirebaseListners();
    checkInitialRoute();

  }

  checkInitialRoute()async{
    Widget route = await Auth().handleAuth();
    setState(() {
      initialRoute = route;
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  getUserLoggedIn() async {
    ChatPreferences.getUserLoggedIn().then((value) => {
          setState(() {
            _isUserLoggedIn = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat Application",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
//        scaffoldBackgroundColor: ThemeColors.white,
//        primarySwatch: ThemeColors.pink,
      ),
//      home: FirebaseMessagingDemo(),
        home: initialRoute,
//        home: Otp(),
//      home: _isUserLoggedIn ? ChatRoomScreen() : SignUpScreen(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        dbHelper.updateUserOnlineStatus(true);
        print("---> resumed");
        break;
      case AppLifecycleState.inactive:
        dbHelper.updateUserOnlineStatus(false);
        print("---> inactive");
        break;
      case AppLifecycleState.paused:
        dbHelper.updateUserOnlineStatus(false);
        print("---> paused");
        break;
      case AppLifecycleState.detached:
        dbHelper.updateUserOnlineStatus(false);
        print("---> detached");
        break;
    }
  }



  _configureFirebaseListners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume $message");
      },
    );
  }
}
