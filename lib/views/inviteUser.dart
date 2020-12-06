import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InviteUserScreen extends StatefulWidget {
  final String groupId;
  final String uid;
  final String hashTag;
  InviteUserScreen(this.groupId, this.uid, this.hashTag);
  @override
  _InviteUserScreenState createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  QuerySnapshot userSnapshot;
  String userState;
  bool haveUserSearched = false;
  TextEditingController emailSearchEditingController = new TextEditingController();

  searchUser() async{
    if(emailSearchEditingController.text.isNotEmpty){
      await DatabaseMethods().getUserByUserEmail(emailSearchEditingController.text).then((val) {
        setState(() {
          userSnapshot = val;
          haveUserSearched = true;
        });
      });
      await DatabaseMethods().isJoined(widget.groupId, emailSearchEditingController.text).then((val) {
        setState(() {
          userState = val;
        });
      });
    }
  }

  addUser(String userId, String username) {
    DatabaseMethods(uid: userId).toggleGroupMembership(widget.groupId, username, widget.hashTag, "ADD_USER").then((val) {
      setState(() {
        userState = val;
      });
    });

  }


  Widget userTile(String username, String email, String userId){

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                Text(email, style: TextStyle(color: Theme.of(context).primaryColor),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                userState == "notYetJoined" ? addUser(userId, username): null;
              },
              child: Container(
                decoration: BoxDecoration(
                    color: userState == "alreadyJoined" ? Colors.grey : Colors.blue,
                    borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(userState == "alreadyJoined" ? "Joined" : "Add", style: simpleTextStyle(),),
              ),
            )
          ],
        )
    );
  }

  Widget userList(){
    return haveUserSearched ? ListView.builder(
      itemCount: userSnapshot.docs.length,
        itemBuilder: (context, index){
        return userTile(
            userSnapshot.docs[index].data()["name"],
            userSnapshot.docs[index].data()["email"],
            userSnapshot.docs[index].id
        );
        }) : Container();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller: emailSearchEditingController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Search user by email",
                          hintStyle: TextStyle(
                              color: Colors.black45
                          ),
                      ),
                    )),
                    SizedBox(width: 15,),
                    GestureDetector(
                      onTap: (){
                        searchUser();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0xfffb934d),
                                    const Color(0xfffb934d)
                                  ]
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(12),
                          child: Image.asset("assets/images/search.png")
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: userList()),
            ],
          ),
        ),
      ),
    );
  }
}
