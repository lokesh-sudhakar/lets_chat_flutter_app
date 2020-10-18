import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/basic_utils.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActiveChatItem extends StatefulWidget {
  final String curUserNumber;
  final ChatUsers chatUsers;

  ActiveChatItem({Key key, this.curUserNumber, this.chatUsers})
      : super(key: key);

  @override
  _ActiveChatItemState createState() => _ActiveChatItemState();
}

class _ActiveChatItemState extends State<ActiveChatItem> {
  String curUser;
  DatabaseHelper dbHelper = DatabaseHelper();
  Stream unReadMsgStream;
  String toUserPhoneNumber;
  String toUserName;
  String chatRoomId;
  QuerySnapshot toUserQuerySnapshot;
  String profileUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    getMyUserName();
    getUnReadMessages();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getUnReadMessages() async {
    curUser = await ChatPreferences.getUserName();
    print(" the data loaded -> ${widget.chatUsers.users}");
    List<dynamic> userList = widget.chatUsers.users;
    userList.remove(widget.curUserNumber);
    toUserPhoneNumber = userList[0];
    toUserQuerySnapshot = await dbHelper.getUserByNumber(toUserPhoneNumber);
    profileUrl = toUserQuerySnapshot.documents[0].data["imageUrl"];
    toUserName = toUserQuerySnapshot.documents[0].data["name"];
    print("to tousername => $toUserName");
    print("to user number => $toUserPhoneNumber");
    chatRoomId = widget.chatUsers.chatRoomId;
    unReadMsgStream =
        dbHelper.getUnReadMsgCount(chatRoomId, widget.curUserNumber);
    setState(() {});
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
                      myName: curUser,
                      curUserPhoneNumber: widget.curUserNumber,
                      profileUrl: profileUrl,
                    )));
      },
      child: StreamBuilder(
          stream: unReadMsgStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Column(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          leading: profileUrl == null || profileUrl.isEmpty
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage:
                                      AssetImage("assets/chat_man.png"),
                                  maxRadius: 30,
                                )
                              : AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(profileUrl),
                                        )),
                                  ),
                                ),
                          title: Text(
                            toUserName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.black,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            widget.chatUsers.lastMessage,
                            style: TextStyle(
                                color: snapshot.data.documents[0]
                                            .data["unreadMessages"] >
                                        0
                                    ? ThemeColors.blue
                                    : Colors.grey.shade500,
                                fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  BasicUtils.readTimestamp(
                                      widget.chatUsers.lastMessageTime),
                                  style: TextStyle(
                                      color: snapshot.data.documents[0]
                                                  .data["unreadMessages"] >
                                              0
                                          ? ThemeColors.blue
                                          : Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ),
                              snapshot.data.documents[0]
                                          .data["unreadMessages"] >
                                      0
                                  ? Container(
                                      height: 20,
                                      width: 22,
                                      child: Center(
                                        child: Text(
                                          snapshot.data.documents[0]
                                              .data["unreadMessages"]
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                          color: ThemeColors.blue),
                                    )
                                  : Container(
                                      width: 0,
                                      height: 0,
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        indent: 100,
                        thickness: 1,
                        endIndent: 20,
                      ),
                    ],
                  )
                : Container(
                    width: 0,
                    height: 0,
                  );
          }),
    );
  }
}
