
import 'package:chat_app/utils/chat_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {

  Future getUserByNumber(String phoneNumber) async {
    return await Firestore.instance.collection("users").where("phoneNumber",isEqualTo: phoneNumber).getDocuments();
  }

  Future getUserByEmail(String email) {
    return Firestore.instance.collection("users").where("email",isEqualTo: email).getDocuments();
  }

  void uploadUserInfo(userMap) async {
    Firestore.instance.collection("users").add(userMap);
  }

  Future<void> uploadUserDataUsingPhoneNumber(String phoneNumber, Map<String,dynamic> userMap) async {
      return Firestore.instance.collection("users")
          .document(phoneNumber).setData(userMap,merge: true);
  }

  Future<DocumentSnapshot> getSavedImageUrl(String phoneNumber) async {
      return await Firestore.instance.collection("users").document(phoneNumber).get();
  }

  Future createChatRoom(String chatRoomId, Map chatRoomMap) async {
      await Firestore.instance.collection("ChatRoom").document(chatRoomId).setData(chatRoomMap,merge: true);
  }

  Future<String> createGroupChat(Map chatRoomMap) async {
    String documentId;
    DocumentReference documentReference = await Firestore.instance.collection("ChatRoom").add(chatRoomMap);
    documentId = documentReference.documentID;
    Map<String,dynamic> userMap = {
      "chatRoomId" : documentId
    };
    await Firestore.instance.collection("ChatRoom").document(documentId).setData(userMap,merge: true);
    return documentId;
  }

  Future<String> getChatRoomId(String toUserPhoneNumber,String curUserPhoneNumber) async{
    QuerySnapshot querySnapshot = await Firestore.instance.collection("ChatRoom")
        .where("users",arrayContains: [toUserPhoneNumber,curUserPhoneNumber]).getDocuments();
    return querySnapshot.documents[0].documentID;
  }

  addUsersToConversation(String chatRoomId,String userId ,messageMap) async {
    await Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").document(userId)
        .setData(messageMap).catchError((e){
      print(e.toString());
    });
  }
  
  Future<QuerySnapshot> getRegisteredNumbers(List<String> contacts) async {
    return await Firestore.instance.collection("users").where("phoneNumber",whereIn: contacts).getDocuments();
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

  setUserActiveOnChat(String curUserPhoneNumber,bool isActive, String chatRoomId) async  {
    Map<String,dynamic> userMap = {
      "active" : isActive
    };
    print("chatRoom id update active -> $chatRoomId");
    print("cur user update active -> $curUserPhoneNumber");
    print("is active update active -> $isActive");
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").document(curUserPhoneNumber).updateData(userMap).catchError((err)=>{
          print("Error -> ${err.toString()}")
    });
  }

  Future<Stream<QuerySnapshot>> getUserStatus(String toUser)async {
    return  Firestore.instance.collection("users")
        .where("name",isEqualTo: toUser).snapshots();
  }

  Stream<QuerySnapshot> getChatRooms(String phoneNumber)  {
    print("user phone number -> $phoneNumber");
    return Firestore.instance.collection("ChatRoom")
        .where("users",arrayContains: phoneNumber).orderBy("lastMessageTime",descending:true).snapshots();
  }

  Stream<QuerySnapshot> getUnReadMsgCount(String chatRoomId, String curUserNumber) {
    return  Firestore.instance.collection("ChatRoom")
        .document(chatRoomId).collection("user").where("phoneNumber",isEqualTo: curUserNumber).snapshots();
  }

  removeFirebaseTokenOnLogout() async {
    Map<String,dynamic> userMap = {
      "firebase_token" :  ""
    };
    String phoneNumber =  await ChatPreferences.getPhoneNumber();
//    QuerySnapshot querySnapshot = await Firestore.instance.collection("users").where("phoneNumber",isEqualTo: phoneNumber).getDocuments();
//    String documentId = querySnapshot.documents[0].documentID;
    print("removal of token on logout documentid -> $phoneNumber");
    Firestore.instance.collection("users")
        .document(phoneNumber).updateData(userMap);
  }

  updateUserOnlineStatus(bool isOnline) async{
    Map<String,dynamic> userMap = {
      "online" : isOnline
    };
    String phoneNumber =  await ChatPreferences.getPhoneNumber();
    if (phoneNumber!= null && phoneNumber.isNotEmpty) {
      print("update status documentid -> $phoneNumber");
      Firestore.instance.collection("users").document(phoneNumber).updateData(userMap);
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


  Future<QuerySnapshot> getAllUsers() async {
    return await Firestore.instance.collection("users").getDocuments();
  }

}
