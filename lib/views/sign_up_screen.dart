import 'package:chat_app/model/user.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/sign_in_screen.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {

  final Function toggle;

  SignUpScreen({this.toggle});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthMethod authMethod = AuthMethod();
  DatabaseHelper dbHelper = DatabaseHelper();
  ChatPreferences preferences = ChatPreferences();
  QuerySnapshot userInfoSnapshot;

  void signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      User user = await authMethod.signUpWithEmailAndPassword(emailController.text, passwordController.text);
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ChatRoomScreen()
        ));
        Map<String,String> userMap = {
          "name" : usernameController.text,
          "email" : emailController.text,
          "firebase_token" :  await ChatPreferences.getFirebaseToken()
        };
        getUserDetails();
        ChatPreferences.saveUserLoggedIn(true);
        ChatPreferences.saveUserName(usernameController.text);
        ChatPreferences.saveUserEmail(emailController.text);
        dbHelper.updateUserOnlineStatus(true);
        dbHelper.uploadUserInfo(userMap);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void getUserDetails() {
    dbHelper.getUserByEmail(emailController.text).then((value) {
      userInfoSnapshot = value;
      print("debug ${userInfoSnapshot.documents.toString()} ${emailController.text}");
      ChatPreferences.saveUserEmail(emailController.text);
      if (userInfoSnapshot.documents!= null && userInfoSnapshot.documents.isNotEmpty) {
        ChatPreferences.saveUserName(userInfoSnapshot.documents[0].data["name"]);
      }
    });
  }

  bool isValidEmail(String email) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "Flutter Connect"),
      body:  isLoading ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value.length<=4) {
                          return "Username should have minimum length of 5";
                        } else {
                          return null;
                        }
                      },
                      controller: usernameController,
                      style: textFieldStyle(),
                      decoration: textFieldInputDecoration("Username"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (!isValidEmail(value.trim())){
                          return "Enter valid email";
                        } else {
                          return null;
                        }
                      },
                      controller: emailController,
                      style: textFieldStyle(),
                      decoration: textFieldInputDecoration("email"),
                    ),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value.length<8) {
                          return "Password should have minimum length of 8";
                        } else {
                          return null;
                        }
                      },
                      controller: passwordController,
                      style: textFieldStyle(),
                      decoration: textFieldInputDecoration("password"),
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
                  //todo
                  signUp();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 15.0,),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.blue
                  ),
                  child: Text("Sign up",style: TextStyle(
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
                child: Text("Sign up with Google",style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),),
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an acount? ",style: textFieldStyle(),),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => SignInScreen()
                      ));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Signin now",style: TextStyle(
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
