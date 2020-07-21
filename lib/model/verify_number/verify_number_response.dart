
import 'package:chat_app/enums/enums.dart';
import 'package:flutter/material.dart';
class VerifyNumberResponse {

  VerifyPhoneCallbackEvent event;
  String message;

  VerifyNumberResponse({@required this.event, @required this.message});
}