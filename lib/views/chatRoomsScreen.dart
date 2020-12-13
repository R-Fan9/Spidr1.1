import 'package:SpidrApp/helper/authenticate.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/auth.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversation_screen.dart';
import 'package:SpidrApp/views/personalReplies.dart';
import 'package:SpidrApp/views/viewJoinRequests.dart';
import 'package:SpidrApp/views/createChatRoom.dart';
import 'package:SpidrApp/views/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();

  Stream myChatsStream;
  Stream mySpectateStream;

  List spectating = [];


  Widget mySpectTile(String hashTag, String groupId, String admin, String groupState, bool waitListed){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(groupId, hashTag, admin, Constants.myUserId, waitListed, false)));
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: Colors.orangeAccent,
                width: 3.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text(hashTag, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),)),
    );
  }

  Widget mySpectChatList(){
    return StreamBuilder(
        stream: mySpectateStream,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(snapshot.data.docs.length > 0){
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return mySpectTile(
                      snapshot.data.docs[index].data()["hashTag"],
                      snapshot.data.docs[index].data()["groupId"],
                      snapshot.data.docs[index].data()["admin"],
                      snapshot.data.docs[index].data()['chatRoomState'],
                      true,
                    );
                  });
            }else{
              return noGroupWidget();
            }

          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }



  Widget myChatTile(String hashTag, String groupId, String admin, List<dynamic> joinRequestsList, String groupState, int newMessages, bool waitListed){
    int numOfRequests = joinRequestsList.length;
    return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => ConversationScreen(groupId, hashTag, admin, Constants.myUserId, waitListed, false)));
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(40)
                    ),
                    child: Text("${hashTag.substring(1,2).toUpperCase()}",style:TextStyle(color:Colors.white),),
                  ),
                  newMessages > 0 ? Positioned(
                      child: Container(
                        height: 15,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(40)
                        ),
                        child: Text("$newMessages",style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold),),
                      )
                  ) : SizedBox.shrink()
                ],
                overflow: Overflow.visible,

              ),
              SizedBox(width: 8,),
              Text(hashTag, style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold,),),
              SizedBox(width: 8,),
              admin == Constants.myUserId + '_' + Constants.myName ? Container(
                width: 10,
                height: 10,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor
                ),
              ) : SizedBox.shrink(),
              Spacer(),
              numOfRequests > 0 ? admin == Constants.myUserId + '_' + Constants.myName ? GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => JoinRequestsScreen(joinRequestsList, groupId, hashTag)
                  ));
                },
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.orangeAccent,
                            width: 3.0
                        ),
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text("$numOfRequests Join Request", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),)
                ),
              ) : SizedBox.shrink() : SizedBox.shrink()
            ],
          ),
        )
    );
  }

  Widget myGroupChatList(){
    return StreamBuilder(
        stream: myChatsStream,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String admin = snapshot.data.docs[index].data()["admin"];
                  return Constants.myUserId + '_' + Constants.myName == admin ? myChatTile(
                    snapshot.data.docs[index].data()["hashTag"],
                    snapshot.data.docs[index].data()["groupId"],
                    admin,
                    snapshot.data.docs[index].data()['joinRequests'],
                    snapshot.data.docs[index].data()['chatRoomState'],
                    snapshot.data.docs[index].data()['newMessages'],
                    false,
                  ):myChatTile(
                    snapshot.data.docs[index].data()["hashTag"],
                    snapshot.data.docs[index].data()["groupId"],
                    admin,
                    [],
                    snapshot.data.docs[index].data()['chatRoomState'],
                    snapshot.data.docs[index].data()['newMessages'],
                    false,
                  )
                  ;
                });
          }else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }

  getSpectating() async{
    await DatabaseMethods(uid: Constants.myUserId).getUserById().then((val){
      if(val.data()['spectating'].length > 0) {
        setState(() {
          spectating = val.data()['spectating'];
        });
        getSpectChats();
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    getGroupChats();
    getSpectating();
    super.initState();
  }

  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("You are not spectating any group"),
          ],
        )
    );
  }

  getGroupChats() async {
    DatabaseMethods(uid: Constants.myUserId).getMyChats(Constants.myName)
        .then((val) {
      setState(() {
        myChatsStream = val;
      });
    });
  }

  getSpectChats() async {
    DatabaseMethods(uid: Constants.myUserId).getSpectatingChats(Constants.myName)
        .then((val) {
      setState(() {
        mySpectateStream = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Image.asset("assets/images/SpidrLogo.png", height: 50,),
            actions: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => PersonalRepliesScreen()
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.contacts),
                ),
              ),
              GestureDetector(
                onTap: (){
                  authMethods.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => Authenticate()
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app),
                ),
              )
            ]
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spectating.length > 0 ? Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: EdgeInsets.all(15.0),
                    child: Text("Spectating", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
                ) : SizedBox.shrink(),
                spectating.length > 0 ? Container(
                    height: 70.0,
                    child: mySpectChatList()
                ) : SizedBox.shrink(),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: EdgeInsets.all(15.0),
                    child: Text("My Chats", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)
                ),
                myGroupChatList()
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 10,),
            FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              heroTag: "cgc",
              child: Icon(Icons.add),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CreateChatRoom(Constants.myUserId)
                ));
              },
            ),
            SizedBox(height: 10,),
            FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              heroTag: "ssn",
              child: Icon(Icons.search),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SearchScreen(Constants.myUserId, "", null)
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

