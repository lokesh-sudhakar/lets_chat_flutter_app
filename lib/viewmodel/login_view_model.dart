import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/model/verify_number/verify_number_response.dart';
import 'package:chat_app/viewmodel/base_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class LoginViewModel extends BaseViewModel {

  BehaviorSubject<VerifyNumberResponse> _responeSubject;
  String verificationId;
  bool showLoading = false;

  LoginViewModel() {
    _responeSubject = new BehaviorSubject<VerifyNumberResponse>.seeded(VerifyNumberResponse(event: VerifyPhoneCallbackEvent.stable,message: ""));
  }


  Stream<VerifyNumberResponse> get responseStream => _responeSubject.stream;

  String numberWithCountryCode(String number) {
    return "+91$number";
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {

    _responeSubject.sink.add(VerifyNumberResponse(
        event: VerifyPhoneCallbackEvent.loading,));

    debugPrint("phone number -> ${numberWithCountryCode(phoneNumber)}");
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
    };

    final PhoneVerificationFailed failed = (AuthException authException) {
      debugPrint('Auth failed reason -> ${authException.message}');
      _responeSubject.sink.add(VerifyNumberResponse(
          event: VerifyPhoneCallbackEvent.failed,
          message:authException.message));
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async{
      this.verificationId = verificationId;
      debugPrint("code sent - $verificationId");
      _responeSubject.sink.add(VerifyNumberResponse(
          event: VerifyPhoneCallbackEvent.codeSent,
          message: "Code sent successfully"));
    };

    final PhoneCodeAutoRetrievalTimeout timeOut = (String verificationId) {
      this.verificationId = verificationId;
      _responeSubject.sink.add(VerifyNumberResponse(
        event: VerifyPhoneCallbackEvent.timeOut,
        message: "Time out"
      ));
      debugPrint("time out - $verificationId");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: numberWithCountryCode(phoneNumber),
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified, verificationFailed: failed,
        codeSent: codeSent, codeAutoRetrievalTimeout: timeOut);
  }

  @override
  dispose()  {
    _responeSubject?.close();
    super.dispose();
  }
}

