import 'package:chat_app/firebase/firebase_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingDemo extends StatefulWidget {
  FirebaseMessagingDemo() : super();

  @override
  _FirebaseMessagingDemoState createState() => _FirebaseMessagingDemoState();
}

class _FirebaseMessagingDemoState extends State<FirebaseMessagingDemo> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Message> messageList;


  _getToken() {
    _firebaseMessaging.getToken().then((token) => {print(token)});
  }

  _configureFirebaseListners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage $message");
        _setmessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch $message");
        _setmessage(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume $message");
        _setmessage(message);
      },
    );
  }

  _setmessage(Map<String, dynamic> messages) {
    var notification = messages["notification"];
    var data = messages["data"];
    final String body = notification["body"];
    final String title = notification["title"];
    final String message = data["message"];
    Message m = Message(title,body,message);
    setState(() {
      print("message length -> ${m.toString()}");
      messageList.add(m);
      print("message length -> ${messageList.length}");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messageList = List();
    _getToken();
    _configureFirebaseListners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Demo"),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: messageList == null ? 0: messageList.length,
            itemBuilder: (context, index) {
            print("message -> ${messageList[index].message}");
              return Card(
                color: Colors.yellow,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(messageList[index].message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),),
                ),
              );
            }
        ),
      ),
    );
  }
}
