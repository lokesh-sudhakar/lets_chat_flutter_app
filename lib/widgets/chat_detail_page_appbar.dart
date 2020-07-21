import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatDetailPageAppBar extends StatelessWidget implements PreferredSizeWidget{

  Stream<QuerySnapshot> stream;
  String name;
  String profileUrl;
  bool isOnline;

  ChatDetailPageAppBar({this.name,this.stream});


  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      flexibleSpace: StreamBuilder(
        stream: stream,
        builder: (context,snapshot) {
          isOnline = snapshot.data.documents[0].data["online"];
          profileUrl = snapshot.data.documents[0].data["imageUrl"];
        return SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
                SizedBox(width: 2,),
                profileUrl != null && profileUrl.isNotEmpty?
                CachedNetworkImage(
                  imageUrl: profileUrl,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fadeOutDuration: const Duration(seconds: 1),
                  fadeInDuration: const Duration(seconds: 3),
                )
                    : CircleAvatar(
                  backgroundImage: AssetImage("images/chat_man.png"),
                  maxRadius: 20,
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(name,style: TextStyle(fontWeight: FontWeight.w600),),
                      SizedBox(height: 6,),
                      isOnline ? Text("Online",style: TextStyle(color: Colors.green,fontSize: 12),):
                      Container(height: 0,width: 0,),
                    ],
                  ),
                ),
                Icon(Icons.more_vert,color: Colors.grey.shade700,),
              ],
            ),
          ),
        );
        }
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}