import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/group_chat/group_chat_item.dart';
import 'package:chat_app/views/group_chat/select_participants_screen.dart';
import 'package:chat_app/views/login_page.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/chat_room_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatListingScreen extends StatefulWidget {
  @override
  _ChatListingScreenState createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Auth authMethod = Auth();
  DatabaseHelper dbHelper = DatabaseHelper();
  String curUser;
  String curUserPhoneNumber;
  Stream chatList;

  @override
  void initState() {
    super.initState();
    getActiveChat();
    dbHelper.updateUserOnlineStatus(true);
  }

  getActiveChat() async {
    curUser = await ChatPreferences.getUserName();
    curUserPhoneNumber = await ChatPreferences.getPhoneNumber();
    setState(() {
      chatList = dbHelper.getChatRooms(curUserPhoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColors.white,
        title: Text(
          "Chats",
          style: TextStyle(
              fontSize: 30,
              color: ThemeColors.black,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showLogoutAlertDialoge(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: ThemeColors.lightBlue,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.power_settings_new,
                      color: ThemeColors.blue,
                      size: 16,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 16,
                          color: ThemeColors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: ValueKey(Icons.search),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchScreen()));
              },
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: ValueKey(Icons.group_add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectParticipantsScreen()));
              },
              child: Icon(
                Icons.group_add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: chatRoomList(),
    );
  }

  void showLogoutAlertDialoge(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Logout"),
            content: Text("Do you wish to logout from chat application"),
            actions: [
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  authMethod.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatList,
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Center(
                child: CircularProgressIndicator(),
              )
            : snapshot.data.documents.length == 0
                ? Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/chat_home.png',
                            width: 300,
                            height: 300,
                            fit: BoxFit.fill,
                          ),
                          Text(
                            "Opps, You dont have chats",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    key: _listKey,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      QuerySnapshot querySnapshot =
                          snapshot.data as QuerySnapshot;
                      print(
                          "chat document id => ${querySnapshot.documents[index].documentID}");
                      ChatUsers chatUsers = ChatUsers.fromJsonWithRoomId(
                          querySnapshot.documents[index].data,
                          querySnapshot.documents[index].documentID);
                      return !chatUsers.isGroupChat
                          ? ActiveChatItem(
                              key: ValueKey(querySnapshot.documents[index].documentID),
                              curUserNumber: curUserPhoneNumber,
                              chatUsers: chatUsers,
                            )
                          : GroupChatItem(
                              key: ValueKey(querySnapshot.documents[index].documentID),
                              curUserNumber: curUserPhoneNumber,
                              chatUsers: chatUsers,
                            );
                    },
                  );
      },
    );
  }
}
