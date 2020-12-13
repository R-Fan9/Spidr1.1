import 'dart:io';
import 'dart:typed_data';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:SpidrApp/views/personalChatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SpidrApp/views/conversation_screen.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';


class FeedPageScreen extends StatefulWidget {
  @override
  _FeedPageScreenState createState() => _FeedPageScreenState();
}

class _FeedPageScreenState extends State<FeedPageScreen> {

  Map<String, Stream<dynamic>> myChats = {};
  List spectatingChats = [];

  findChats(String groupId){
    return DatabaseMethods(uid: Constants.myUserId).getMessagesForFeed(groupId);
  }

  String _destructureFGroupInfo(String group) {
    return group.substring(0, group.indexOf('_'));
  }

  String _destructureSGroupInfo(String group) {
    return group.substring(group.indexOf('_') + 1);
  }

  getChats() async{
    Map<String, Stream<dynamic>> groupAndChats = {};
    await DatabaseMethods(uid: Constants.myUserId).getUserById().then((user) async{
      setState(() {
        spectatingChats = user.data()['spectating'];
      });
      for(var group in user.data()['myChats']){
        if(!groupAndChats.containsKey(group)){
          groupAndChats[group] = await findChats(_destructureFGroupInfo(group)) as Stream;
        }
      }
      for(var group in user.data()['joinedChats']){
        if(!groupAndChats.containsKey(group)){
          groupAndChats[group] = await findChats(_destructureFGroupInfo(group)) as Stream;
        }
      }
      for(var group in user.data()['spectating']){
        if(!groupAndChats.containsKey(group)){
          groupAndChats[group] = await findChats(_destructureFGroupInfo(group)) as Stream;
        }
      }
    });

    return groupAndChats;

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChats().then((val){
      setState(() {
        myChats = val;
      });
    });
  }

  replyFeed(String groupId, String userId, String userName, String text, String dateTime, int sendTime, Map imgMap, String messageId) async{

      await DatabaseMethods(uid: Constants.myUserId).createPersonalChat(userId, userName, text, dateTime, sendTime,
          imgMap, null, groupId, messageId).then((personalChatId){

        DatabaseMethods(uid: Constants.myUserId).updateConversationMessages(groupId, messageId, personalChatId, Constants.myUserId+"_"+Constants.myName, "ADD_REPLY");
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => PersonalChatScreen(personalChatId, userName, userId, false)));
      });


  }

  Widget feedTile(Map imgObj,
      String sender,
      String senderId,
      String sendDate,
      int sendTime,
      String groupId,
      String hashTag,
      String admin,
      String messageId,
      List replies
      ){
    bool replied = false;
    int numOfReplies = 0;
    for(var reply in replies){
      if(reply.containsKey(Constants.myUserId+"_"+Constants.myName)){
        replied = true;
      }
      if(!reply["open"]){
        numOfReplies ++;
      }
    }

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(25.0)
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 6.0
                      )
                    ]
                  ),
                  child: CircleAvatar(),
                ),
                title: Text(
                  hashTag, style: TextStyle(
                    fontWeight: FontWeight.bold),
                ),
                subtitle: Text(Constants.myUserId == senderId ? "Me" : sender),

                trailing: Constants.myUserId == senderId ? numOfReplies > 0 ?
                GestureDetector(
                  onTap: (){
                    showRepliedUsers(replies, messageId, groupId, context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 6.0
                          )
                        ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Text(
                      numOfReplies > 1 ? numOfReplies.toString() + " users replied" : numOfReplies.toString() + " user replied",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.5),
                    ),
                  ),
                ):SizedBox.shrink() : SizedBox.shrink(),

              ),
              Container(
                margin: EdgeInsets.all(10.0),
                width: double.infinity,
                height: 400.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(0,5),
                      blurRadius: 8.0
                    )
                  ],
                  image: DecorationImage(
                    image: NetworkImage(imgObj['imgUrl']),
                    fit: BoxFit.fitWidth
                  )
                ),
              ),
              imgObj['caption'] != '' ?
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      child: Text(imgObj['caption'], style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400),),

                    ),
                  ) : SizedBox.shrink(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.forward),
                                  color: Colors.orange,

                                  iconSize: 30.0,
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ConversationScreen(
                                            groupId,
                                            hashTag,
                                            admin,
                                            Constants.myUserId,
                                            spectatingChats.contains(groupId + "_" + hashTag),
                                          false
                                        )
                                    )
                                    );
                                  }
                              ),
                            ],
                          ),
                          Constants.myUserId != senderId ? Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.reply),
                                color: !replied ? Colors.orange : Colors.grey,
                                iconSize: 30.0,
                                onPressed: (){
                                  !replied ?
                                  replyFeed(groupId, senderId, sender, "", sendDate, sendTime, imgObj, messageId) :
                                  null;
                                },
                              ),
                            ],
                          ):SizedBox.shrink()
                        ],
                      ),
                      IconButton(
                          icon: Icon(Icons.share),
                          color: senderId == Constants.myUserId ? Colors.orange : Colors.grey,
                          iconSize: 30.0,
                          onPressed: (){
                            senderId == Constants.myUserId ? getBytes(imgObj['imgPath']).then((bytes){
                              Share.file('Share via', imgObj['imgName'], bytes.buffer.asUint8List(), '*/*');
                            }) : null;
                          })
                    ],
                  ),

              )
            ],
          ),
        ),
    );
  }

  Widget feedList(Stream chats, String groupInfo){
    return StreamBuilder(
        stream: chats,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  String groupId = _destructureFGroupInfo(groupInfo);
                  String hashTagAndAdmin = _destructureSGroupInfo(groupInfo);
                  String hashTag = _destructureFGroupInfo(hashTagAndAdmin);
                  String admin = _destructureSGroupInfo(hashTagAndAdmin);

                  return snapshot.data.docs[index].data()['imgObj'] != null ?
                  feedTile(snapshot.data.docs[index].data()['imgObj'],
                    snapshot.data.docs[index].data()["sendBy"],
                      snapshot.data.docs[index].data()["userId"],
                      snapshot.data.docs[index].data()["dateTime"],
                      snapshot.data.docs[index].data()["time"],
                      groupId,
                      hashTag,
                      admin,
                      snapshot.data.docs[index].id,
                      snapshot.data.docs[index].data()["replies"],
                  ):
                  Container();
                });
          }else{
            return Container();
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
      child: Scaffold(
        appBar: appBarMain(context),
        body: Container(
          color: Colors.white,
          child: ListView.builder(
              itemCount: myChats.length,
              itemBuilder: (context, index){
                return feedList(myChats[myChats.keys.elementAt(index)], myChats.keys.elementAt(index));
              }),
        )
      ),
    );
  }


  Future getBytes (String imgPath) async{
    Uint8List bytes = File(imgPath).readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }
}
