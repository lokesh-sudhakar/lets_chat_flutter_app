import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/model/message_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/group_chat/send_message_widget.dart';
import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';


class GroupChatRoom extends StatefulWidget {

  final String curUserNumber;
  final ChatUsers chatUsers;


  GroupChatRoom(this.chatUsers,this.curUserNumber);

  @override
  _GroupChatRoomState createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {

  DatabaseHelper dbHelper = DatabaseHelper();
  Stream<QuerySnapshot> chatMessageStream;



  @override
  void initState() {
    super.initState();
    dbHelper.setUserActiveOnChat(widget.curUserNumber,true,widget.chatUsers.chatRoomId);
    dbHelper.getConversationMessages(widget.chatUsers.chatRoomId).then((value)  {
      setState(() {
        chatMessageStream = value;
      });
    });
  }

  @override
  void dispose() {
    dbHelper.setUserActiveOnChat(widget.curUserNumber,false,widget.chatUsers.chatRoomId);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            print("pop");
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back,color: Colors.black,),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace:  SafeArea(
                left: true,
                child: Container(
                  padding: EdgeInsets.only(right: 16),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 50),
                      ),
                      SizedBox(width: 2,),
                      AspectRatio(
                        aspectRatio: 1 / 1,
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage("assets/group_icon.png",),
                              )),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(widget.chatUsers.groupName,style: TextStyle(fontWeight: FontWeight.w600),),
                            SizedBox(height: 6,),
                            Text(widget.chatUsers.users.join(", "),
                              style: TextStyle(color: Colors.grey,fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert,color: Colors.grey.shade700,),
                    ],
                  ),
                ),
              )

        ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(child: chatMessageList()),
            Divider(
              height: 6,
            ),
            SendMessageWidget(
              onSendClick: sendMessage
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context,snapshot) {
        print ("has data -> ${snapshot.hasData}");
        return snapshot.hasData ? Container(
          child: ListView.builder(
              reverse: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                MessageData chatMessage = MessageData.fromMap(snapshot.data.documents[index].data);
                print("messages -> ${chatMessage.message}");
                return ChatBubble(chatMessage:chatMessage,isSentByMe: chatMessage.sentBy == widget.curUserNumber,);
              }
          ),
        ):Container(width: 0,height: 0,);
      },
    );
  }

  void sendMessage(String message) async {
    if (message.isNotEmpty) {
      MessageData chatMessage = MessageData(
          message: message,
          sentBy: widget.curUserNumber,
          timeStamp: DateTime.now().millisecondsSinceEpoch,
          sentByUser: await ChatPreferences.getUserName()
      );
      dbHelper.addConversationMessages(widget.chatUsers.chatRoomId, chatMessage.toMap());
      debugPrint("chat room id -> ${widget.chatUsers.chatRoomId},username - ${widget.curUserNumber}, message ${message} ");
    }
  }

}
