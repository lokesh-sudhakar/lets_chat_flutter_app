import 'package:chat_app/colors.dart';
import 'package:chat_app/model/chatroom/chat_users.dart';
import 'package:chat_app/model/chatroom/user_chat_room_data.dart';
import 'package:chat_app/model/user/user_upload_data.dart';
import 'package:chat_app/services/database_helper.dart';
import 'package:chat_app/utils/chat_preference.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool showLoading = false;
  TextEditingController searchController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  QuerySnapshot searchResultSnapshot;
  String illustrationText;

  initiateSearch() {
    setState(() {
      showLoading = true;
    });
    dbHelper.getUserByNumber("+91"+searchController.text).then((value) => {
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
    illustrationText = "";
  }

  createChatRoomForConversation({String toUserPhoneNumber,String toUserName,String photoUrl}) async{

    String curUser = await ChatPreferences.getUserName();
    String curUserPhoneNumber = await ChatPreferences.getPhoneNumber();
    List users = [toUserPhoneNumber,curUserPhoneNumber];
    String chatRoomId = getChatRoomId(curUserPhoneNumber, toUserPhoneNumber);
    ChatUsers chatUsers = ChatUsers(chatRoomId: chatRoomId,users: users);
    print("chatroom id -> $chatRoomId");
    await dbHelper.createChatRoom(chatRoomId,chatUsers.toJson());
    UserChatRoomData curUserChatData =UserChatRoomData(phoneNumber: curUserPhoneNumber,
        active: true,userName: curUser,unreadMessages: 0,);
    UserChatRoomData toUserChatData =UserChatRoomData(phoneNumber: toUserPhoneNumber,
      active: false,userName: toUserName,unreadMessages: 0,);
    await dbHelper.addUsersToConversation(chatRoomId,curUserPhoneNumber,curUserChatData.toJson());
    await dbHelper.addUsersToConversation(chatRoomId,toUserPhoneNumber,toUserChatData.toJson());
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ConversationScreen(toUserName: toUserName,
          chatRoomId: chatRoomId,myName: curUser,
          curUserPhoneNumber: curUserPhoneNumber,profileUrl: photoUrl,)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

       /* appBar: AppBar(
          elevation: 0,
          backgroundColor: ThemeColors.white,
          iconTheme: new IconThemeData(color: ThemeColors.blue),
          title: Text(
            "Search",
            style: TextStyle(
                color: ThemeColors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),*/
        body: Container(
          color: Colors.black12,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Color(0x54FFFFFF),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back,color: ThemeColors.blue,),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        child: TextField(
                          onChanged: (String value) {
                            if (value != null) {
                              if (value.length == 10) {
                                initiateSearch();
                              } else if (value.isEmpty){
                                setState(() {});
                              }
                            }
                          },
                          controller: searchController,
                          keyboardType: TextInputType.number,
                          inputFormatters:[
                            WhitelistingTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          decoration: InputDecoration(
                            prefixText: "+91",
                            hintText: "Search registered number",
                            counterText: "",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                            prefixIcon: Icon(Icons.search,color: Colors.grey.shade400,size: 20,),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            focusedBorder: OutlineInputBorder(
//                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100
                                )
                            ),
                            contentPadding: EdgeInsets.all(8),
                            enabledBorder: OutlineInputBorder(
//                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: showLoading ? Center(child: CircularProgressIndicator()) : searchList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchList() {
    return searchResultSnapshot != null && searchResultSnapshot.documents.length!=0?
    ListView.builder(
      itemCount: searchResultSnapshot.documents.length,
      shrinkWrap: true,
        itemBuilder: (context, index) {
      return searchItem(UserUploadData.fromJson(searchResultSnapshot.documents[index].data));
      })
        : Container(child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/search_not_found.png',
            width: 300,
            height: 300,
            fit: BoxFit.fill,
          ),
          Text(searchController.text.length ==10?"Search number is not registered":"",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold
          ),)
        ],
      ),
    ),);
  }

  Widget searchItem(UserUploadData userData) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        createChatRoomForConversation(
            toUserName: userData.userName,
            toUserPhoneNumber: userData.phoneNumber,
            photoUrl: userData.imageUrl);
      },
      child: Container(
        color: ThemeColors.white,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListTile(
          leading: userData.imageUrl==null || userData.imageUrl.isEmpty
              ? CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
            AssetImage("assets/chat_man.png"),
            maxRadius: 20,
          )
              : AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(userData.imageUrl),
                  )),
            ),
          ),
          title: Text(
            userData.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ThemeColors.black,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            userData.phoneNumber,
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
        ),
      ),
    );
//      Container(
//      padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 20.0),
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: [
//          Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Text(name,style: TextStyle(
//                color: Colors.white,
//              ),),
//              Text(phoneNumber,style: TextStyle(color: Colors.white),) ,
//            ],
//          ),
//          GestureDetector(
//            onTap: () {
//              createChatRoomForConversation(toUserPhoneNumber: phoneNumber,toUserName: name);
//            },
//            child: Container(
//              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
//              decoration: BoxDecoration(
//                color: Colors.blue,
//                borderRadius: BorderRadius.circular(20.0),
//              ),
//              child: Text("Message",style: TextStyle(color: Colors.white),),
//            ),
//          )
//        ],
//      ),
//    );
  }
}


  String getChatRoomId(String user1Number,String user2Number) {
    if (user1Number.compareTo(user2Number) < 0) {
      return "$user1Number\_$user2Number";
    } else {
      return "$user2Number\_$user1Number";
    }
  }
