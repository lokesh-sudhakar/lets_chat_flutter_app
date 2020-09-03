import 'dart:io';

import 'package:chat_app/model/base_response.dart';
import 'package:chat_app/model/image_upload_response.dart';
import 'package:chat_app/model/user/user_upload_data.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/viewmodel/base_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as path;


class RegistrationViewModel extends BaseViewModel {

  String phoneNumber;
  BehaviorSubject<UserUploadData> _userDataSubject;
  BehaviorSubject<bool> _uploadUserDataSubject;
  BehaviorSubject<ImageUploadResponse> _uploadImageSubject;

  RegistrationViewModel() {
    this._userDataSubject = BehaviorSubject<UserUploadData>();
    this._uploadUserDataSubject = BehaviorSubject<bool>();
    this._uploadImageSubject = BehaviorSubject<ImageUploadResponse>();
  }

  Stream<UserUploadData> get userDataStream => _userDataSubject.stream;

  Stream<bool> get uploadDataStream => _uploadUserDataSubject.stream;

  Stream<ImageUploadResponse> get imageUploadResultStream => _uploadImageSubject.stream;


  uploadUserData(String userName, String phoneNumber, String status) async {
    debugPrint("hellow");
    UserUploadData userUploadData = UserUploadData(
        phoneNumber: phoneNumber,
        userName: userName,
        status: status,
        firebaseToken: await ChatPreferences.getFirebaseToken(),
        online: true);
    dbHelper.uploadUserDataUsingPhoneNumber(
        phoneNumber, userUploadData.toJson())
        .whenComplete(() {
      ChatPreferences.saveProfileCompleted(true);
      ChatPreferences.saveUserName(userName);
      debugPrint("true");
      _uploadUserDataSubject.sink.add(true);
    }).catchError((value) {
      debugPrint("false");
      _uploadUserDataSubject.sink.add(false);
    });
  }

  void getUserProfileData(String phoneNumber) async {
    this.phoneNumber = phoneNumber;
    debugPrint("cur user phone number$phoneNumber");
    DocumentSnapshot documentSnapshot = await dbHelper.getSavedImageUrl(
        phoneNumber).catchError((err) {
      _userDataSubject.sink.add(UserUploadData.empty(message: err.toString()));
      _uploadImageSubject.sink.add(ImageUploadResponse(imageUrl:_userDataSubject.stream.value.imageUrl,isLoading: false));
    });
    if (documentSnapshot.data != null) {
      UserUploadData userData = UserUploadData.fromJson(documentSnapshot.data);
      userData.message = "Profile fetched successful";
      _userDataSubject.sink.add(userData);
      _uploadImageSubject.sink.add(ImageUploadResponse(imageUrl:_userDataSubject.stream.value.imageUrl,isLoading: false));
    } else {
      _userDataSubject.sink.add(
          UserUploadData.empty(message: "user does not exist"));
      _uploadImageSubject.sink.add(ImageUploadResponse(imageUrl:_userDataSubject.stream.value.imageUrl,isLoading: false));
    }

  }

  Future pickImage(String existingImageUrl) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    if (pickedFile!= null) {
      uploadImage(File(pickedFile.path), path.basename(pickedFile.path), existingImageUrl);
    }
  }

  uploadImage(File file, String fileName, String existingImageUrl) async {
    _uploadImageSubject.sink.add(ImageUploadResponse(isLoading: true,imageUrl:_userDataSubject.stream.value.imageUrl));
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        fileName);
    storageReference
        .putFile(file)
        .onComplete
        .then((firebaseFile) async {
      deleteExistingProfileImage(existingImageUrl);
      String downloadUrl = await firebaseFile.ref.getDownloadURL();
      Map<String, dynamic> imageMap = {"imageUrl": downloadUrl};
      dbHelper.uploadUserDataUsingPhoneNumber(phoneNumber, imageMap).then((
          value) {
      _uploadImageSubject.sink.add(ImageUploadResponse(imageUrl:downloadUrl,isSuccesful: true,isLoading: false, message: "Image upload successful"));
      }).catchError((err) {
        _uploadImageSubject.sink.add(ImageUploadResponse(isSuccesful: false,isLoading: false, message: "Failed to upload image"));
      });
    }).catchError((err) async {
      _uploadImageSubject.sink.add(ImageUploadResponse(isSuccesful: false,isLoading: false, message: "Failed to upload image"));
    });
  }

  deleteExistingProfileImage(String existingImageUrl) async {
    if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      StorageReference existingPhotoRef = await FirebaseStorage.instance.getReferenceFromUrl(
          existingImageUrl);
      existingPhotoRef?.delete();
    }
  }
}