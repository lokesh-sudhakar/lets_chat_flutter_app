import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {

  final String name;
  final String email;
//  final String photoUrl;
  SearchItem(this.name,this.email, );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,style: TextStyle(
                  color: Colors.white,
              ),),
              Text(email,style: TextStyle(color: Colors.white),),
            ],
          ),
          GestureDetector(
            onTap: () {

            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text("Message",style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }
}
