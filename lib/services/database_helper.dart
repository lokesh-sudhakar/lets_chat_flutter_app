
import 'package:chat_app/utils/chat_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {

  Future getUserByName(String userName) {
    return Firestore.instance.collection("users").where("name",isEqualTo: userName).getDocuments();
  }

  Future getUserByEmail(String email) {
    return Firestore.instance.collection("users").where("email",isEqualTo: email).getDocuments();
  }

  void uploadUserInfo(userMap) async {
      Firestore.instance.collection("users").add(userMap);
  }


  Future createChatRoom(String chatRoomId, Map chatRoomMap) async {
      await Firestore.instance.collection("ChatRoom")
          .document(chatRoomId).setData(chatRoomMap);
  }

  addUsersToConversation(String chatRoomId,String userId ,messageMap) async {
    await Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").document(userId)
        .setData(messageMap).catchError((e){
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomId, messageMap) {
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("chats")
        .add(messageMap).catchError((e){
          print(e.toString());
    });
  }

   Future<Stream<QuerySnapshot>> getConversationMessages(String chatRoomId) async  {
     return Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("chats")
        .orderBy('time',descending: true)
        .snapshots();
  }

  setUserActiveOnChat(String curUser,bool isActive, String chatRoomId) async  {
    Map<String,dynamic> userMap = {
      "active" : isActive
    };
    print("chatRoom id update active -> $chatRoomId");
    print("cur user update active -> $curUser");
    print("is active update active -> $isActive");
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").document(curUser).updateData(userMap).catchError((err)=>{
          print("Error -> ${err.toString()}")
    });

  }

  Future<Stream<QuerySnapshot>> getUserStatus(String toUser)async {
    return  Firestore.instance.collection("users")
        .where("name",isEqualTo: toUser).snapshots();
  }

  getChatRooms(String userName) async {
    print("username -> $userName");
    return Firestore.instance.collection("ChatRoom")
        .where("users",arrayContains: userName).snapshots();
  }

  Stream<QuerySnapshot> getUnReadMsgCount(String chatRoomId, String myName) {
    return  Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").where("userName",isEqualTo: myName).snapshots();
  }

  removeFirebaseTokenOnLogout() async {
    Map<String,dynamic> userMap = {
      "firebase_token" :  ""
    };
    String email =  await ChatPreferences.getUserEmail();
    QuerySnapshot querySnapshot = await Firestore.instance.collection("users").where("email",isEqualTo: email).getDocuments();
    String documentId = querySnapshot.documents[0].documentID;
    print("removal of token on logout documentid -> $documentId");
    Firestore.instance.collection("users")
        .document(documentId).updateData(userMap);
  }

  updateUserOnlineStatus(bool isOnline) async{
    Map<String,dynamic> userMap = {
      "online" : isOnline
    };
    String email =  await ChatPreferences.getUserEmail();
    if (email!= null && email.isNotEmpty) {
      QuerySnapshot querySnapshot = await Firestore.instance.collection("users").where("email", isEqualTo:email).getDocuments();
      String documentId = querySnapshot.documents[0].documentID;
      print("update status documentid -> $documentId");
      Firestore.instance.collection("users").document(documentId).updateData(userMap);
    }
  }


  pushFirebaseTokenOnSignin(String email) async {
    print("pushing token -> $email");
    String token = await ChatPreferences.getFirebaseToken();
    Map<String,dynamic> userMap = {
      "firebase_token" :  token,
    };
    print("pushing token on sign in -> $token");
    QuerySnapshot querySnapshot = await Firestore.instance.collection("users").where("email",isEqualTo: email).getDocuments();
    String documentId = querySnapshot.documents[0].documentID;
    print("documentid -> $documentId");
    Firestore.instance.collection("users")
        .document(documentId).updateData(userMap);
  }

}
