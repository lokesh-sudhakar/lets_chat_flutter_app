
class UserUploadData{

  String userName;
  String status;
  String firebaseToken;
  String phoneNumber;
  String imageUrl;
  bool online;
  String message;


  UserUploadData({this.phoneNumber,this.imageUrl,this.userName,this.firebaseToken,this.status,this.online});
  UserUploadData.empty({this.phoneNumber="",this.imageUrl="",
    this.userName="",this.firebaseToken="",this.status="",this.online=false,this.message});


  UserUploadData.fromJson(Map<String , dynamic> data) {
    this.userName = data["name"];
    this.phoneNumber  = data["phoneNumber"];
    this.status = data['status'];
    this.online = data['online'];
    this.firebaseToken = data['firebase_token'];
    this.imageUrl = data['imageUrl'];
  }


  Map<String,dynamic> toJson () {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userName!= null)  data['name'] = this.userName;
    if (this.phoneNumber!= null) data['phoneNumber'] = this.phoneNumber;
    if (this.status!= null)  data['status'] = this.status;
    if (this.online!= null)  data['online'] = this.online;
    if (this.firebaseToken!= null) data['firebase_token'] = this.firebaseToken;
    if (this.imageUrl != null) data['imageUrl'] = this.imageUrl;
    return data;
  }
}