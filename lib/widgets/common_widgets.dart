import 'package:chat_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


showToast(BuildContext context,String msg) {

  Widget toast = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey,
    ),
    child: Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
//        Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Expanded(child: Text(msg,maxLines: 3,)),
        ],
      ),
    ),
  ));
  FlutterToast(context).showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
  );
}


Widget appBar(BuildContext context,String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: ThemeColors.pink),
      ),
    );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: ThemeColors.pink,
      ),
      border: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(25.0),
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: ThemeColors.pink
          )
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: ThemeColors.pink
          )
      )
  );
}

TextStyle textFieldStyle(){
  return  TextStyle(
  color: ThemeColors.black,
    fontSize: 14.0,
  );
}

TextStyle mediumTextFieldStyle(){
  return  TextStyle(
    color: ThemeColors.black,
    fontSize: 17.0,
  );
}
