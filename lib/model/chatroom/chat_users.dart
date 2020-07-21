class ChatUsers {

  String chatRoomId;
  String lastMessage;
  int lastMessageTime;
  List<dynamic> users;

  ChatUsers({this.chatRoomId,this.users,this.lastMessage ="",this.lastMessageTime=0});

  ChatUsers.fromJson(Map<String,dynamic> map){
    this.users = map['users'];
    this.lastMessage = map['lastMessage'];
    this.chatRoomId = map['chatRoomId'];
    this.lastMessageTime = map['lastMessageTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.chatRoomId!= null) data['chatRoomId'] = this.chatRoomId;
    if (this.users!= null)  data['users'] = this.users;
    if (this.lastMessage!= null) data['lastMessage'] = this.lastMessage;
    if (this.lastMessageTime!= null) data['lastMessageTime'] = this.lastMessageTime;
    return data;
  }



}