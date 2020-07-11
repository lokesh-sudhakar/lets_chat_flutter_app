class ChatUsers {

  String chatRoomId;
  List<dynamic> users;

  ChatUsers({this.chatRoomId,this.users});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.chatRoomId!= null)  data['chatRoomId'] = this.chatRoomId;
    if (this.users!= null)  data['users'] = this.users;
    return data;
  }

}