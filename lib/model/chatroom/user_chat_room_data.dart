
class UserChatRoomData {

  String phoneNumber;
  String userName;
  int unreadMessages;
  bool active;

  UserChatRoomData({this.phoneNumber,this.userName,
    this.unreadMessages,this.active});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.phoneNumber!= null) data['phoneNumber'] = this.phoneNumber;
    if (this.userName!= null)  data['userName'] = this.userName;
    if (this.unreadMessages!= null)  data['unreadMessages'] = this.unreadMessages;
    if (this.active!= null)  data['active'] = this.active;
    return data;
  }
}