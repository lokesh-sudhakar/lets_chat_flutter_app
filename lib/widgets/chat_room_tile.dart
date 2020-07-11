import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:flutter/material.dart';

import 'common_widgets.dart';

class ActiveChatItem extends StatefulWidget {

  final String curUserName;
  String chatRooomId;
  int unreadMsgCount;
  final document;

//  ActiveChatItem({this.userName, this.chatRooomId,this.unreadMsgCount});

  ActiveChatItem.usingDoc({this.curUserName,this.document});


  @override
  _ActiveChatItemState createState() => _ActiveChatItemState();
}

class _ActiveChatItemState extends State<ActiveChatItem> {

  String curUser;
  DatabaseHelper dbHelper = DatabaseHelper();
  Stream unReadMsgStream;
  String toUserName;
  String chatRoomId;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    getMyUserName();
    print(" the data loaded -> ${widget.document.data["users"]}");
    List<dynamic> userList = widget.document.data["users"];
    userList.remove(widget.curUserName);
    toUserName = userList[0];
    print("to tousername => $toUserName");
    print("to usruser => ${widget.curUserName}");
    chatRoomId = widget.document.data["chatRoomId"];
    unReadMsgStream = dbHelper.getUnReadMsgCount(chatRoomId,widget.curUserName);
  }

  void getMyUserName() async {
    curUser = await ChatPreferences.getUserName();
    print("to usruser => $curUser");

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ConversationScreen(
                      toUserName: toUserName,
                      chatRoomId: chatRoomId,
                      myName: widget.curUserName,
                    )));
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: ListTile(
          leading: Container(
            height: 40,
            width: 40,
            child: Center(
              child: Text(
                toUserName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Colors.blue),
          ),
          title: Text(
            toUserName,
            style: mediumTextFieldStyle(),
          ),
          trailing: StreamBuilder(
            stream: unReadMsgStream,
            builder: (context,snapshot) {
              print("has data -> ${snapshot.hasData}");
              return snapshot.hasData ? Container(
                height: 20,
                width: 20,
                child: Center(
                  child: Text(
                    snapshot.data.documents[0].data["unreadMessages"].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.green),
              ): Container(width: 0,height: 0,);
            },

          ),
        ),
      ),
    );
  }
}
