import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/viewJoinRequests.dart';
import 'package:chat_app/views/createChatRoom.dart';
import 'package:chat_app/views/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();

  Stream myChatsStream;

  Widget myGroupChatList(){
    return StreamBuilder(
      stream: myChatsStream,
        builder: (context, snapshot){
        if(snapshot.hasData){
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
              return myChatTile(snapshot.data.docs[index].data()["hashTag"],
                  snapshot.data.docs[index].data()["groupId"],
                  snapshot.data.docs[index].data()["admin"],
                  snapshot.data.docs[index].data()['joinRequests'],
                  snapshot.data.docs[index].data()['chatRoomState']
              );
              });
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }



  Widget myChatTile(String hashTag, String groupId, String admin, List<dynamic> joinRequestsList, String groupState){
    int numOfRequests = joinRequestsList.length;
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(groupId, hashTag, admin, Constants.myUserId)));
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
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


  @override
  void initState() {
    // TODO: implement initState
    getGroupChats();
    super.initState();
  }

  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("You've not joined any group"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/spidr_logo.jpg", height: 50,),
        actions: [
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
        color: Colors.white,
        child: Column(
          children: [
            Expanded(child: myGroupChatList()),
          ],
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
    );
  }
}





