import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/sign_up_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase/firebase_messaging_demo.dart';

void main() {
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
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black12,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
//      home: FirebaseMessagingDemo(),
      home: _isUserLoggedIn ? ChatRoomScreen() : SignUpScreen(),
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
