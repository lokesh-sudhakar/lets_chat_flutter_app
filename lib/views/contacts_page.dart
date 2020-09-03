import 'package:chat_app/model/user/user_upload_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../colors.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {


  Iterable<Contact> contacts;
  List<String> contactList = List();
  List<UserUploadData> usersData = List();
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalContacts();
  }

  Future<List<UserUploadData>>  checkIfCaontactIsRegistered(List<String> contacts) async {
    QuerySnapshot querySnapshot= await dbHelper.getRegisteredNumbers(contacts);
    List<UserUploadData> usersData = List();
    for (int i =0;i< querySnapshot.documents.length; i++) {
      usersData.add(UserUploadData.fromJson(querySnapshot.documents[i].data));
    }
    return usersData;
  }

  Future getLocalContacts() async {
    PermissionStatus permissionStatus= await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      contacts = await ContactsService.getContacts();
      contacts.forEach((contact) {
//        contactList.add(contact.phones);
        contact.phones.forEach((element) {
          contactList.add(element.value.replaceAll(" ", "").replaceAll("(", "").replaceAll(")", ""));
          debugPrint(element.value);
          debugPrint(contact.displayName);
        });
      });
      List<UserUploadData> data = await checkIfCaontactIsRegistered(contactList);
      setState(() {
        usersData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsIconTheme: IconThemeData(
          color: ThemeColors.black,
        ),
        elevation: 0,
        backgroundColor: ThemeColors.white,
        title: Text(
          "Contacts",
          style: TextStyle(
              fontSize: 30,
              color: ThemeColors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: usersData.isEmpty? Center(child: CircularProgressIndicator(),):
            Container(
              child: ListView.builder(
                itemCount: usersData.length,
                  itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(usersData[index].userName, style: TextStyle(color: Colors.black),),
                    subtitle: Text(usersData[index].phoneNumber, style: TextStyle(color: Colors.black),),
                  );
                  }
              ),
            )
      ),
    );
  }
}
