import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/model/chatroom/user_chat_room_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/basic_utils.dart';
import 'package:chat_app/views/group_chat/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'group_chat_room.dart';

class GroupChatItem extends StatefulWidget {
  final String curUserNumber;
  final ChatUsers chatUsers;

  GroupChatItem({Key key, this.curUserNumber, this.chatUsers})
      : super(key: key);

  @override
  _GroupChatItemState createState() => _GroupChatItemState();
}

class _GroupChatItemState extends State<GroupChatItem> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Stream<QuerySnapshot> unReadMsgStream;
  UserChatRoomData userChatRoomData;

  @override
  void initState() {
    super.initState();
    getUnReadMessages();
  }

  void getUnReadMessages() async {
    unReadMsgStream = dbHelper.getUnReadMsgCount(
        widget.chatUsers.chatRoomId, widget.curUserNumber);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    GroupChatRoom(widget.chatUsers, widget.curUserNumber)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: StreamBuilder(
            stream: unReadMsgStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.documents.length == 1) {
                QuerySnapshot querySnapshot = snapshot.data as QuerySnapshot;
                debugPrint("group doc ${querySnapshot.documents.length}");
                userChatRoomData =
                    UserChatRoomData.fromJson(querySnapshot.documents[0].data);
              }
              return snapshot.hasData && snapshot.data.documents.length == 1
                  ? Column(
                      children: <Widget>[
                        ListTile(
                          leading: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage("assets/group_icon.png"),
                                  )),
                            ),
                          ),
                          title: Text(
                            widget.chatUsers.groupName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.black,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            widget.chatUsers.lastMessage,
                            style: TextStyle(
                                color: userChatRoomData.unreadMessages > 0
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
                                      color: userChatRoomData.unreadMessages > 0
                                          ? ThemeColors.blue
                                          : Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                              ),
                              userChatRoomData.unreadMessages > 0
                                  ? Container(
                                      height: 20,
                                      width: 22,
                                      child: Center(
                                        child: Text(
                                          userChatRoomData.unreadMessages
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
      ),
    );
  }
}
