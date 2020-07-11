import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/views/sign_in_screen.dart';
import 'package:chat_app/widgets/chat_room_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {

  AuthMethod authMethod = AuthMethod();
  DatabaseHelper dbHelper = DatabaseHelper();
  String curUser;
  Stream chatList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getActiveChat();
    dbHelper.updateUserOnlineStatus(true);
  }

  getActiveChat() async{
    curUser = await ChatPreferences.getUserName();
    dbHelper.getChatRooms(curUser).then((value) => {
    setState(() {
      chatList = value;
    })
    });
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatList,
      builder: (context,snapshot) {
        return !snapshot.hasData ? Container() : ListView.builder(
          itemCount: snapshot.data.documents.length,
            itemBuilder: (context,index) {
//              print(" the data loaded -> ${snapshot.data.documents[index].data["users"]}");
//              List<dynamic> userList = snapshot.data.documents[index].data["users"];
//              userList.remove(curUser);
//              String toUser = userList[0];
//              print("chatroom -> ${userList[0]}");
//              return ActiveChatItem(userName: toUser,
//                chatRooomId: snapshot.data.documents[index].data["chatRoomId"],);
            return ActiveChatItem.usingDoc(document: snapshot.data.documents[index],curUserName: curUser,);
            },);
      },
    );
  }

  Future<bool> _onWillPop() async {
    dbHelper.updateUserOnlineStatus(false);
    return await Future.delayed(Duration(milliseconds: 500),() {
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Room", style: TextStyle(
            color: Colors.white,
          ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                authMethod.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => SignInScreen()
                ));
              },
              child: Container(
                padding: EdgeInsets.all(4.0),
                  child: IconButton(icon: Icon(Icons.exit_to_app,color: Colors.white,),)),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen()
            ));
          },
          child: Icon(Icons.search,color: Colors.white,),
        ),
        body: Container(
          child: Container(
            child: chatRoomList(),
          ),
        ),
      ),
    );
  }
}
