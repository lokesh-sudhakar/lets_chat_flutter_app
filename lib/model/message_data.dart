import 'package:flutter/material.dart';

class MessageData{
  String message;
  String sentBy;
  int timeStamp;
  String sentByUser;
  MessageData({@required this.message,@required this.sentBy,@required this.timeStamp,@required this.sentByUser});


  MessageData.fromMap(Map<String,dynamic> map) {
    this.message = map["message"];
    this.sentBy = map["sentBy"];
    this.timeStamp = map["time"];
    this.sentByUser = map["sentByUser"];
  }

  Map<String,dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.message!=null) data["message"] = this.message;
    if (this.sentBy!=null) data["sentBy"] = this.sentBy;
    if (this.timeStamp!= null) data["time"] = this.timeStamp;
    if (this.sentByUser!=null) data["sentByUser"] = this.sentByUser;
    return data;
  }
}