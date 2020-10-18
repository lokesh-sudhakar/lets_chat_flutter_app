import 'package:chat_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';

class SendMessageWidget extends StatefulWidget {

  final void Function(String) onSendClick;

  SendMessageWidget({this.onSendClick});

  @override
  _SendMessageWidgetState createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {

  TextEditingController _messageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  controller: _messageController,
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
                onPressed: () {
                  widget.onSendClick(_messageController.value.text);
                  _messageController.text = "";
                },
                child: Icon(Icons.send,color: Colors.white,),
                backgroundColor: ThemeColors.blue,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
