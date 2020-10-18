
class UserChatRoomData {

  String phoneNumber;
  String userName;
  int unreadMessages;
  bool active;

  UserChatRoomData({this.phoneNumber,this.userName,
    this.unreadMessages,this.active});

  UserChatRoomData.fromJson(Map<String, dynamic> map) {
    this.phoneNumber = map['phoneNumber'];
    this.userName = map['userName'];
    this.unreadMessages = map['unreadMessages'];
    this.active = map['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.phoneNumber!= null) data['phoneNumber'] = this.phoneNumber;
    if (this.userName!= null)  data['userName'] = this.userName;
    if (this.unreadMessages!= null)  data['unreadMessages'] = this.unreadMessages;
    if (this.active!= null)  data['active'] = this.active;
    return data;
  }
}