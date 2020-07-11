import 'package:chat_app/model/chat_users.dart';
import 'package:chat_app/model/user_chat_room_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool showLoading = false;
  TextEditingController searchController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  QuerySnapshot searchResultSnapshot;

  initiateSearch() {
    setState(() {
      showLoading = true;
    });
    dbHelper.getUserByName(searchController.text).then((value) => {
          setState(() {
            showLoading = false;
            searchResultSnapshot = value;
          })
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  createChatRoomForConversation({String toUserName}) async{

    String curUser = await ChatPreferences.getUserName();
    String chatRoomId = getChatRoomId(toUserName, curUser);
    List users = [toUserName,curUser];
    UserChatRoomData curUserChatData =UserChatRoomData(
        active: true,userName: curUser,unreadMessages: 0,);
    UserChatRoomData toUserChatData =UserChatRoomData(
      active: false,userName: toUserName,unreadMessages: 0,);
    ChatUsers chatUsers = ChatUsers(chatRoomId: chatRoomId,users: users);
    await dbHelper.addUsersToConversation(chatRoomId,curUser,curUserChatData.toJson());
    await dbHelper.addUsersToConversation(chatRoomId,toUserName,toUserChatData.toJson());
    await dbHelper.createChatRoom(chatRoomId, chatUsers.toJson());
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ConversationScreen(toUserName: toUserName,chatRoomId: chatRoomId,myName: curUser,)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "Search"),
      body: Container(
        color: Colors.black12,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Color(0x54FFFFFF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search users",
                          hintStyle: TextStyle(
                            color: Colors.white70,
                          ),
                          border: InputBorder.none,
                        ),
                        style: textFieldStyle()),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: showLoading ? Center(child: CircularProgressIndicator()) : searchList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchList() {
    return searchResultSnapshot != null ?
    ListView.builder(
      itemCount: searchResultSnapshot.documents.length,
      shrinkWrap: true,
        itemBuilder: (context, index) {
      return searchItem(searchResultSnapshot.documents[index].data["name"],
          searchResultSnapshot.documents[index].data["email"]);
    }) : Container();
  }

  Widget searchItem(String name,String email) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,style: TextStyle(
                color: Colors.white,
              ),),
              Text(email,style: TextStyle(color: Colors.white),),
            ],
          ),
          GestureDetector(
            onTap: () {
              createChatRoomForConversation(toUserName: name);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text("Message",style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }
}


getChatRoomId(String user1,String user2) {
  if (user1.substring(0,1).codeUnitAt(0) > user2.substring(0,1).codeUnitAt(0)) {
    return "$user1\_$user2";
  } else {
    return "$user2\_$user1";
  }
}
