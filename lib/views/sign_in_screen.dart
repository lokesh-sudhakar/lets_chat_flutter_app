import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/sign_up_screen.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {

  final Function toggle;

  SignInScreen({this.toggle});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  AuthMethod authMethod = AuthMethod();
  DatabaseHelper dbHelper = DatabaseHelper();
  bool isLoading  = false;
  QuerySnapshot userInfoSnapshot;

  bool isValidEmail(String email) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }

  void signIn() async {
    setState(() {
      isLoading =true;
    });
    User user = await authMethod.signInWithEmailAndPassword(emailController.text, passwordController.text);
    if (user != null) {

      ChatPreferences.saveUserLoggedIn(true);
      getUserDetails();
    }
    setState(() {
      isLoading =false;
    });
  }

  void getUserDetails() {
    dbHelper.getUserByEmail(emailController.text).then((value) {
      userInfoSnapshot = value;
      print("debug ${userInfoSnapshot.documents.toString()}");
      ChatPreferences.saveUserEmail(emailController.text);
      if (userInfoSnapshot.documents!= null && userInfoSnapshot.documents.isNotEmpty) {
        ChatPreferences.saveUserName(userInfoSnapshot.documents[0].data["name"]);
      }
      dbHelper.pushFirebaseTokenOnSignin(emailController.text);
      dbHelper.updateUserOnlineStatus(true);
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ChatRoomScreen()
      ));
    });
  }

  void goToSignUpPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => SignUpScreen()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "Flutter Connect"),
      body:  SingleChildScrollView(
        child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        style: textFieldStyle(),
                        controller: emailController,
                        decoration: textFieldInputDecoration("Email"),
                        validator: (value) {
                          if (!isValidEmail(value.trim())){
                            return "Enter valid email";
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        style: textFieldStyle(),
                        obscureText: true,
                        controller: passwordController,
                        decoration: textFieldInputDecoration("Password"),
                        validator: (value) {
                          if (value.length<8) {
                            return "Password should have minimum length of 8";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
                    child: Text("Forgot Password?",style: textFieldStyle(),),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    signIn();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 15.0,),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.blue
                    ),
                    child: Text("Sign in",style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),),
                  ),
                ),
                SizedBox(height: 16,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 15.0,),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.white
                  ),
                  child: Text("Sign in with Google",style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),),
                ),
                SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have a account? ",style: textFieldStyle(),),
                    GestureDetector(
                      onTap: () {
                        goToSignUpPage();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical:16.0),
                        child: Text("Register Now",style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          decoration: TextDecoration.underline
                        ),),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
      ),
    );
  }
}
