import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class AuthMethod {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper dbHelper = DatabaseHelper();

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(user.uid) : null;
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } on PlatformException catch ( exception,stackTrace) {
      print("exception -> $exception, trace-> $stackTrace");
      return null;
    } catch (exception,stackTrace){
      print("exception -> $exception, trace-> $stackTrace");
      return null;
    }
  }

  String signUpErrorHandling( exception) {
    String errorMessage;
    switch (exception.code) {
      case "ERROR_INVALID_EMAIL":
        errorMessage = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
    return errorMessage;
  }

  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } on PlatformException catch(exception,stactTrace){
      print(signUpErrorHandling(exception));
      print("exception -> $exception, trace-> $stactTrace");
      return null;
    } catch(exception,stactTrace){
      print("exception -> $exception, trace-> $stactTrace");
      return null;
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(exception,stactTrace){
      print("exception -> $exception, trace-> $stactTrace");
    }
  }

  Future signOut() async {
    try {
      dbHelper.updateUserOnlineStatus(false);
      dbHelper.removeFirebaseTokenOnLogout();
      ChatPreferences.clearPreference();
      return await _auth.signOut();
    }catch(exception,stactTrace){
      print("exception -> $exception, trace-> $stactTrace");
    }
  }

}