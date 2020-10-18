class ChatUsers {

  String chatRoomId;
  String lastMessage;
  int lastMessageTime;
  List<dynamic> users;
  bool isGroupChat=false;
  String groupName;

  ChatUsers({this.chatRoomId,this.users,this.lastMessage ="",this.lastMessageTime=0});
  ChatUsers.groupChat({this.users,this.lastMessage ="",this.lastMessageTime=0, this.isGroupChat,this.groupName});


  ChatUsers.fromJson(Map<String,dynamic> map){
    this.users = map['users'];
    this.lastMessage = map['lastMessage'];
    this.chatRoomId = map['chatRoomId'];
    this.lastMessageTime = map['lastMessageTime'];
    this.isGroupChat = map['isGroupChat']??false;
    this.groupName = map['groupName'];
  }

  ChatUsers.fromJsonWithRoomId(Map<String,dynamic> map,String chatRoomId) {
    this.users = map['users'];
    this.lastMessage = map['lastMessage'];
    this.chatRoomId = chatRoomId;
    this.lastMessageTime = map['lastMessageTime'];
    this.groupName = map['groupName'];
    this.isGroupChat = map['isGroupChat']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.chatRoomId!= null) data['chatRoomId'] = this.chatRoomId;
    if (this.users!= null)  data['users'] = this.users;
    if (this.lastMessage!= null) data['lastMessage'] = this.lastMessage;
    if (this.lastMessageTime!= null) data['lastMessageTime'] = this.lastMessageTime;
    if (this.isGroupChat!=null) data['isGroupChat'] = this.isGroupChat;
    if (this.groupName!=null) data['groupName'] = this.groupName;
    return data;
  }
}