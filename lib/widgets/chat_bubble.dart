import 'package:chat_app/colors.dart';
import 'package:chat_app/model/message_data.dart';
import 'package:chat_app/utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final MessageData chatMessage;
  final bool isSentByMe;

  ChatBubble({@required this.chatMessage, this.isSentByMe});

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.isSentByMe
          ? EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.2,
              right: 16,
              top: 8,
              bottom: 8)
          : EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.2,
              left: 16,
              top: 8,
              bottom: 8),
      child: Align(
        alignment: (widget.isSentByMe ? Alignment.topRight : Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:widget.isSentByMe ? BorderRadius.only(
                topLeft: Radius.circular(20),topRight:Radius.circular(20),
                bottomLeft: Radius.circular(20),bottomRight:Radius.circular(0)):
            BorderRadius.only(
                topLeft: Radius.circular(20),topRight:Radius.circular(20),
                bottomLeft: Radius.circular(0),bottomRight:Radius.circular(20)),
            color: (widget.isSentByMe ? Colors.grey.shade200 : Colors.white),
          ),
          padding: EdgeInsets.only(left: 16,right: 16,top: 8,bottom: 8),
          child: Column(
            crossAxisAlignment: widget.isSentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.chatMessage.sentByUser,
                style: TextStyle(color: ThemeColors.blue, fontSize: 12),
              ),
//              Text(widget.chatMessage.message),
              Text(widget.chatMessage.message,
                style: TextStyle(fontSize: 16),
              ),
              Text(
                BasicUtils.readTimestamp(widget.chatMessage.timeStamp,),
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.right,
              ),
//              Row(
//                mainAxisSize: MainAxisSize.min,
//                mainAxisAlignment: MainAxisAlignment.end,
//                crossAxisAlignment: CrossAxisAlignment.baseline,
//                children: <Widget>[
//                  Container(
//                    margin: EdgeInsets.only(right: 10),
//                    child: Text(widget.chatMessage.message,
//                        style: TextStyle(fontSize: 16),
//
//                    ),
//                  ),
//
//
//                ],
//              ),
            ],
          ),
        ),
      ),
    );
  }
}
