import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/chatRoomsScreen.dart';
import 'package:SpidrApp/views/pageView.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupChatSettingsScreen extends StatefulWidget {
  final String groupId;
  final String uid;
  final String hashTag;
  GroupChatSettingsScreen(this.groupId, this.uid, this.hashTag);
  @override
  _GroupChatSettingsScreenState createState() => _GroupChatSettingsScreenState();
}

class _GroupChatSettingsScreenState extends State<GroupChatSettingsScreen> {

  leaveGroupChat(){
    DatabaseMethods(uid: widget.uid).toggleGroupMembership(widget.groupId, Constants.myName, widget.hashTag, "LEAVE_GROUP");
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => PageViewScreen(0)
    ));
  }

  Widget leaveGroupButton(){
    return GestureDetector(
        onTap: (){
          leaveGroupChat();
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Text("LEAVE " + widget.hashTag, style: TextStyle(
                color: Colors.red,
                fontSize: 20
              ),),

            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            leaveGroupButton()
          ],
        ),
      ),
    );
  }
}
