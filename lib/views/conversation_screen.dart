
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/colors.dart';
import 'package:chat_app/model/message_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';


class ConversationScreen extends StatefulWidget {

  final String toUserName;
  final String chatRoomId;
  final String myName;
  final String curUserPhoneNumber;
  final String profileUrl;

  ConversationScreen({this.toUserName,this.chatRoomId,this.myName,this.curUserPhoneNumber,this.profileUrl});

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
    dbhelper.setUserActiveOnChat(widget.curUserPhoneNumber,true,widget.chatRoomId);
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
    dbhelper.setUserActiveOnChat(widget.curUserPhoneNumber,false,widget.chatRoomId);
    super.dispose();
  }


  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      MessageData chatMessage = MessageData(
        message: messageController.text,
        sentBy: await ChatPreferences.getPhoneNumber(),
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        sentByUser: widget.myName
      );
      dbhelper.addConversationMessages(widget.chatRoomId, chatMessage.toMap());
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
                MessageData chatMessage = MessageData.fromMap(snapshot.data.documents[index].data);
                return ChatBubble(chatMessage:chatMessage,isSentByMe: chatMessage.sentBy == widget.curUserPhoneNumber,);
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
        flexibleSpace: StreamBuilder(
            stream: userDataStream,
            builder: (context,snapshot) {
              return SafeArea(
                left: true,
                child: Container(
                  padding: EdgeInsets.only(right: 16),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 50),
                      ),
                      SizedBox(width: 2,),
                      widget.profileUrl==null || widget.profileUrl.isEmpty?
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: AssetImage("assets/chat_man.png"),
                        maxRadius: 20,
                      ):
                      CachedNetworkImage(
                        imageUrl: widget.profileUrl,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.person),
                        imageBuilder: (context, imageProvider) => Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(widget.toUserName,style: TextStyle(fontWeight: FontWeight.w600),),
                            SizedBox(height: 6,),
                            snapshot.hasData ? snapshot.data.documents[0].data["online"]?Text("Online",style: TextStyle(color: Colors.green,fontSize: 12),):
                            Container(height: 0,width: 0,):Container(height: 0,width: 0,),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert,color: Colors.grey.shade700,),
                    ],
                  ),
                ),
              );
            }
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: chatMessageList()),
            Divider(
              height: 6,
            ),
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
                              hintText: "Type message...",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: InputBorder.none
                          ),
                          style: textFieldStyle()),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                        child: FloatingActionButton(
                          onPressed: (){
                            sendMessage();
                          },
                          child: Icon(Icons.send,color: Colors.white,),
                          backgroundColor: ThemeColors.blue,
                          elevation: 0,
                        ),
                      ),
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
