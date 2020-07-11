
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class ConversationScreen extends StatefulWidget {

  final String toUserName;
  final String chatRoomId;
  final String myName;

  ConversationScreen({this.toUserName,this.chatRoomId,this.myName});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  String myName;
  DatabaseHelper dbhelper = DatabaseHelper();
  ScrollController _scrollController;

  _ConversationScreenState();

  TextEditingController messageController = TextEditingController();

  Stream<QuerySnapshot> chatMessageStream;
  Stream<QuerySnapshot> userDataStream;

  @override
  void initState() {
    super.initState();
    dbhelper.setUserActiveOnChat(widget.myName,true,widget.chatRoomId);
    dbhelper.getUserStatus(widget.toUserName).then((value) => {
      userDataStream = value
    });
    dbhelper.getConversationMessages(widget.chatRoomId).then((value)  {
      setState(() {
        chatMessageStream = value;
      });
    });
  }

  @override
  void dispose() {
    dbhelper.setUserActiveOnChat(widget.myName,false,widget.chatRoomId);
    super.dispose();
  }


  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String , dynamic> messageMap = {
        "message" : messageController.text,
        "sentBy" : await ChatPreferences.getUserName(),
        'time' : DateTime.now().millisecondsSinceEpoch
      };
      dbhelper.addConversationMessages(widget.chatRoomId, messageMap);
      messageController.text = "";
    }
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
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
              controller: _scrollController,
            itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                print("messages -> ${snapshot.data.documents[index].data["message"]}");
                print("name => ${widget.myName}");
                return messageTile(snapshot.data.documents[index].data["message"],
                    snapshot.data.documents[index].data["sentBy"] == widget.myName);
              }
          ),
        ):Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.toUserName,
              style: TextStyle(color: Colors.white,fontSize: 16),
            ),
            StreamBuilder(
              stream: userDataStream,
              builder: (context,snapshot) {
                return snapshot.hasData? Text(snapshot.data.documents[0].data["online"] ? "Online": "",
                  style: TextStyle(color: Colors.white,fontSize: 8),
                ):Container();
              },
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: chatMessageList()),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Message",
                            hintStyle: TextStyle(
                              color: Colors.white70,
                            ),
                            border: InputBorder.none,
                          ),
                          style: textFieldStyle()),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(String message, bool isSentByMe) {
    return Container(
      alignment: isSentByMe ? Alignment.centerRight: Alignment.centerLeft,
      padding: EdgeInsets.all(10.0),

      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isSentByMe? Colors.blue : Colors.grey,
          borderRadius: getBorderRadius(isSentByMe)
        ),
        child: Text(message,style: mediumTextFieldStyle(),
        ),
      ),
    );
  }

  BorderRadiusGeometry getBorderRadius(bool isSentByMe) {
    return BorderRadius.only(topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
          bottomRight: isSentByMe ? Radius.circular(0) :  Radius.circular(10.0),
          bottomLeft: isSentByMe ? Radius.circular(10.0) : Radius.circular(0)
    );
  }
}
