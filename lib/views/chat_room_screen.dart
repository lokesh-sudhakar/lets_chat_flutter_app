import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/login_page.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/chat_room_tile.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  Auth authMethod = Auth();
  DatabaseHelper dbHelper = DatabaseHelper();
  String curUser;
  String curUserPhoneNumber;
  Stream chatList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getActiveChat();
    dbHelper.updateUserOnlineStatus(true);
  }

  getActiveChat() async {
    curUser = await ChatPreferences.getUserName();
    curUserPhoneNumber = await ChatPreferences.getPhoneNumber();
    dbHelper.getChatRooms(curUserPhoneNumber).then((value) => {
          setState(() {
            chatList = value;
          })
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
                : ListView.separated(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      ChatUsers chatUsers = ChatUsers.fromJson(
                          snapshot.data.documents[index].data);
                      return ActiveChatItem.usingDoc(
                        curUserNumber: curUserPhoneNumber,
                        chatUsers: chatUsers,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 100,
                        thickness: 1,
                        endIndent: 20,
                      );
                    },
                  );
      },
    );
  }

  Future<bool> _onWillPop() async {
    dbHelper.updateUserOnlineStatus(false);
    return await Future.delayed(Duration(milliseconds: 500), () {
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openContacts();
          },
          child: Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: Container(child: chatRoomList())),
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutAlertDialoge(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Logout"),
            content:
                Text("Do you wish to logout from chat application"),
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage()));
                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }

  void openContacts() async {
    PermissionStatus permissionStatus = await Permission.contacts.status;

    switch (permissionStatus) {
      case PermissionStatus.undetermined : {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.contacts,
        ].request();
        break;
      }
      case PermissionStatus.denied: {
        debugPrint("Contact permission denied");
        Map<Permission, PermissionStatus> statuses = await [
          Permission.contacts,
        ].request();
        break;
      }
      case PermissionStatus.granted: {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SearchScreen()));
        break;
      }
      case PermissionStatus.permanentlyDenied: {
        showContactPermissionDialogue();
        break;
      }
      default:
        throw UnimplementedError();
    }
  }

  void showContactPermissionDialogue() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Contact permission"),
            content:
            Text("To help you message friends and family on chatapp access your contacts."
                " Tap Settings > Permissions, and turn Contcts on."),
            actions: [
              FlatButton(
                child: Text("NOT NOW"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text("SETTINGS"),
              ),
            ],
          );
        });
  }
}
