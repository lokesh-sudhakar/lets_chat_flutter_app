import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/model/chatroom/user_chat_room_data.dart';
import 'package:chat_app/model/user/user_upload_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/group_chat/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectParticipantsScreen extends StatefulWidget {
  @override
  _SelectParticipantsScreenState createState() =>
      _SelectParticipantsScreenState();
}

class _SelectParticipantsScreenState extends State<SelectParticipantsScreen> {
  DatabaseHelper dbHelper = new DatabaseHelper();
  TextEditingController groupTextEditor = TextEditingController();
  List<UserUploadData> users;
  List<UserUploadData> participants = List();
  UserUploadData curUserData;
  bool check = false;
  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  void getAllUsers() async {
    dbHelper.getAllUsers().then((value) async {
      String curUserNumber = await ChatPreferences.getPhoneNumber();
      setState(()  {
        users = List();
        for (DocumentSnapshot documentSnapshot in value.documents) {
          UserUploadData userData =
              UserUploadData.fromJson(documentSnapshot.data);
          if (userData.phoneNumber != curUserNumber) {
            users.add(userData);
          } else {
            curUserData = userData;
          }
        }
      });
    });
  }

  bool validateGroup() {
    if (groupTextEditor.value.text.trim().isNotEmpty &&
        participants.length >= 2) {
      return true;
    } else {
      return false;
    }
  }

  createGroupChat() async {
    setState(() {
      showLoader = true;
    });
    List<String> userList = participants.map((user) {
      return user.phoneNumber;
    }).toList();
    userList.add(curUserData.phoneNumber);
    ChatUsers chatUser = ChatUsers.groupChat(
        users: userList,
        groupName: groupTextEditor.value.text.trim(),
        isGroupChat: true);
    String chatRoomId = await dbHelper.createGroupChat(chatUser.toJson());
    chatUser.chatRoomId = chatRoomId;
    for (UserUploadData userUploadData in participants) {
      UserChatRoomData userChatRoomData = UserChatRoomData(
        phoneNumber: userUploadData.phoneNumber,
        active: false,
        userName: userUploadData.userName,
        unreadMessages: 0,
      );
      dbHelper.addUsersToConversation(
          chatRoomId, userUploadData.phoneNumber, userChatRoomData.toJson());
    }
    UserChatRoomData curChatRoomData = UserChatRoomData(
      phoneNumber: curUserData.phoneNumber,
      active: true,
      userName: curUserData.userName,
      unreadMessages: 0,
    );
    await dbHelper.addUsersToConversation(
        chatRoomId, curUserData.phoneNumber, curChatRoomData.toJson());
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GroupChatRoom(chatUser, curUserData.phoneNumber)));
    setState(() {
      showLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Group"),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if (validateGroup()) createGroupChat();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: validateGroup() ? ThemeColors.blue : Colors.grey.shade500,
          ),
          child: Text(
            "Create Group",
            style: TextStyle(color: ThemeColors.white),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            onChanged: (String value) {
              setState(() {
                validateGroup();
              });
            },
            controller: groupTextEditor,
            keyboardType: TextInputType.number,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: "Group Name",
              counterText: "",
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
              ),
              prefixIcon: Icon(
                Icons.group,
                color: Colors.grey.shade400,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              focusedBorder: OutlineInputBorder(
//                                borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
              contentPadding: EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
//                                borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
            validator: (value) {
              if (value.trim().length == 0) {
                return "Enter valid group name";
              } else {
                return null;
              }
            },
          ),
          Expanded(
            child: Container(
              child: users == null ||  showLoader
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        UserUploadData user = users[index];
                        return CheckboxListTile(
                          value: participants.contains(user),
                          activeColor: ThemeColors.blue,
                          onChanged: (checked) {
                            setState(() {
                              if (checked) {
                                participants.add(user);
                              } else {
                                participants.remove(user);
                              }
                            });
                          },
                          secondary: user == null ||
                                  user.imageUrl == null ||
                                  user.imageUrl.isEmpty
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage:
                                      AssetImage("assets/chat_man.png"),
                                  maxRadius: 30,
                                )
                              : AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(user.imageUrl),
                                        )),
                                  ),
                                ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: Text(
                            user.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.black,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Text(
                            user.phoneNumber,
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                        );
                      }),
            ),
          ),
        ],
      ),
    );
  }
}
