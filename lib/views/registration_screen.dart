import 'dart:io';

import 'package:chat_app/colors.dart';
import 'package:chat_app/locator.dart';
import 'package:chat_app/model/image_upload_response.dart';
import 'package:chat_app/model/user/user_upload_data.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/viewmodel/registration_view_model.dart';
import 'package:chat_app/views/chat_room_screen.dart';
import 'package:chat_app/views/group_chat/chat_listing_screen.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;

class RegistrationScreen extends StatefulWidget {
  final String phoneNumber;

  RegistrationScreen(this.phoneNumber);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  RegistrationViewModel viewModel = locator<RegistrationViewModel>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  String _imageFilePath = "";
  String existingImageUrl;
  Auth _auth = Auth();
  DatabaseHelper dbHelper = DatabaseHelper();
  FlutterToast flutterToast;
  bool isUploading = false;
  UserUploadData userData;
  bool showLoading = false;

  bool isValidEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    ChatPreferences.saveProfileCompleted(false);
    ChatPreferences.savePhoneNumber(widget.phoneNumber);
    ChatPreferences.saveUserLoggedIn(true);
    flutterToast = FlutterToast(context);
    viewModel.getUserProfileData(widget.phoneNumber);
    _listenToUploadData();
    _listenToImageUploadData();
//    getExistingImageProfile();
  }

  _listenToImageUploadData() {
    viewModel.imageUploadResultStream.listen((event) {
      if (event!= null && event.isSuccesful!= null ) {
        if (event.isSuccesful) {
          showToast(context, event.message);
        } else {
          showToast(context, event.message);
        }
      }
    });
  }

  _listenToUploadData() {
    viewModel.uploadDataStream.listen((isSuccessful) {
      debugPrint("submit successful - $isSuccessful");
      if (isSuccessful!= null) {
        setState(() {
          showLoading = false;
        });
        if (isSuccessful) {
          showToast(context, "Submit successful");
          moveToChatListingScreen();
        } else {
          showToast(context, "Something went wrong");
        }
      }
    });
  }

  void moveToChatListingScreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) =>
              //ChatRoomScreen()
              ChatListingScreen()
      ));
    });
  }

  Future pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    setState(() {
      _imageFilePath = pickedFile.path;
    });
    uploadImage(File(_imageFilePath), path.basename(_imageFilePath));
  }

  uploadImage(File file, String fileName) async {
    setState(() {
      isUploading = true;
    });
    StorageReference existingPhotoRef;
    if (existingImageUrl != null && existingImageUrl.isNotEmpty)
      existingPhotoRef =
          await FirebaseStorage.instance.getReferenceFromUrl(existingImageUrl);
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    storageReference.putFile(file).onComplete.then((firebaseFile) async {
      String downloadUrl = await firebaseFile.ref.getDownloadURL();
      Map<String, dynamic> imageMap = {
        "imageUrl": downloadUrl,
      };
      setState(() {
        userData.imageUrl = null;
        isUploading = false;
      });
      _showToast(context, "Image upload successful");
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        existingPhotoRef.delete().then((value) {
          _showToast(context, "Image delete successful");
        });
      }
      dbHelper.uploadUserDataUsingPhoneNumber(widget.phoneNumber, imageMap);
    }).catchError((err) async {
      setState(() {
        isUploading = false;
      });
      print("Image error ${err.toString()}");
      _showToast(context, "image upload error");
    });
  }

  _showToast(BuildContext context, String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(msg),
        ],
      ),
    );
    FlutterToast(context).showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColors.white,
        centerTitle: true,
        title: Text(
          "COMPLETE PROFILE ",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: ThemeColors.black),
        ),
      ),
      body: StreamBuilder<UserUploadData>(
          stream: viewModel.userDataStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || showLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              usernameController.text = snapshot.data.userName;
              statusController.text = snapshot.data.status;
              return SingleChildScrollView(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding:
                      EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
                  child: Column(
                    children: [
                      buildProfileImage(snapshot),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.length <= 4) {
                                    return "Username should have minimum length of 5";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: usernameController,
                                style: TextStyle(
                                  color: ThemeColors.black,
                                ),
                                decoration: InputDecoration(
                                  focusColor: ThemeColors.blue,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/ic_user_name.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  labelText: "Username",
                                  fillColor: ThemeColors.blue,
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: TextFormField(
                                controller: statusController,
                                style: textFieldStyle(),
                                minLines: 3,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  focusColor: ThemeColors.blue,
                                  labelText: "Status",
                                  alignLabelWithHint: true,
                                  fillColor: ThemeColors.blue,
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (formKey.currentState.validate()) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                  viewModel.uploadUserData(usernameController.text,
                                      widget.phoneNumber,
                                      statusController.text);
//                                  uploadUserData();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: Colors.blue),
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget buildProfileImage(AsyncSnapshot<UserUploadData> snapshot) {
    return StreamBuilder<ImageUploadResponse>(
      stream: viewModel.imageUploadResultStream,
      builder: (context, imageRespnseSnapshot) {
        return imageRespnseSnapshot.hasData? Container(
          margin: EdgeInsets.only(top: 20.0),
          child: GestureDetector(
            onTap: () {
              viewModel.pickImage(imageRespnseSnapshot.data.imageUrl);
              },
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageRespnseSnapshot.data.imageUrl != null &&
                              imageRespnseSnapshot
                                  .data.imageUrl.isNotEmpty
                              ? NetworkImage(
                              imageRespnseSnapshot.data.imageUrl)
                              : AssetImage(
                              "assets/add_profile_image_small.png")),
                    ),
                  ),
                  imageRespnseSnapshot.data.isLoading
                      ? Container(
                    width: 150.0,
                    height: 150.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  )
                      : Container(
                    height: 0,
                    width: 0,
                  ),
                ],
              ),
            ),
          ),
        ):
        Container(width: 0,height: 0,);
      }
    );
  }
}
