import 'package:flutter/material.dart';


Widget appBar(BuildContext context,String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
    );
}


InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white54,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.blue
          )
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.white54
          )
      )
  );
}

TextStyle textFieldStyle(){
  return  TextStyle(
  color: Colors.white,
    fontSize: 14.0,
  );
}

TextStyle mediumTextFieldStyle(){
  return  TextStyle(
    color: Colors.white,
    fontSize: 17.0,
  );
}
