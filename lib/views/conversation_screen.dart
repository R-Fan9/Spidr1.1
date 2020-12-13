import 'dart:io';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/camera.dart';
import 'package:SpidrApp/views/groupChatSettings.dart';
import 'package:SpidrApp/views/personalChatScreen.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:full_screen_image/full_screen_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart'as Path;

import 'inviteUser.dart';

class ConversationScreen extends StatefulWidget {
  final String groupChatId;
  final String hashTag;
  final String admin;
  final String uid;
  final bool spectate;
  final bool joinChat;
  ConversationScreen(this.groupChatId, this.hashTag, this.admin, this.uid, this.spectate, this.joinChat);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();

  Stream chatMessageStream;
  List<String> highlightWords = [];
  bool searchKeyWord = false;

  TextEditingController replyEditingController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    !widget.spectate ? !widget.joinChat ? DatabaseMethods(uid: Constants.myUserId).openChat(widget.groupChatId, widget.hashTag) : null : null;
    DatabaseMethods(uid: widget.uid).getConversationMessages(widget.groupChatId).then((val) {
      setState(() {
        chatMessageStream = val;
      });
    });

    super.initState();
  }

  sendMessage(){
    if(messageController.text.isNotEmpty){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(now);

      DatabaseMethods(uid: widget.uid).addConversationMessages(widget.groupChatId, widget.hashTag, messageController.text,
          Constants.myName, formattedDate, now.microsecondsSinceEpoch, null);
      messageController.text = "";

      DatabaseMethods(uid: widget.uid).addNotification(widget.groupChatId, widget.hashTag);
    }
  }

  deleteMessage(String messageId){
    DatabaseMethods(uid: widget.uid).deleteConversationMessages(widget.groupChatId, messageId).then((val){
      setState(() {
        chatMessageStream = val;
      });
    });
  }


  replyMessage(String userId, String userName, String text, String dateTime, int sendTime, Map imgMap, String messageId)async{
    if(formKey.currentState.validate()){
      String replyMessage = replyEditingController.text;
      DateTime now = DateTime.now();
      String formattedDateTime = DateFormat('yyyy-MM-dd hh:mm a').format(now);
      Map<String, dynamic> replyMap = {
        'text': replyMessage,
        'sender':Constants.myName,
        'senderId': widget.uid,
        'formattedDateTime': formattedDateTime,
        'sendTime':now.microsecondsSinceEpoch,
        'imgMap': null};

      await DatabaseMethods(uid: widget.uid).createPersonalChat(userId, userName, text, dateTime, sendTime, imgMap, replyMap, widget.groupChatId, messageId).then((personalChatId){

        DatabaseMethods(uid: widget.uid).updateConversationMessages(widget.groupChatId, messageId, personalChatId, widget.uid+"_"+Constants.myName, "ADD_REPLY");
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => PersonalChatScreen(personalChatId, userName, userId, false)));
      });

    }
  }

  Widget messageTile(String message,
      Map imgObj,
      String sendBy,
      String dateTime,
      int time,
      String userId,
      bool isSendByMe,
      String messageId,
      String admin,
      List replies){

    bool replied = false;
    int numOfReplies = 0;
    for(var reply in replies){
      if(reply.containsKey(widget.uid+"_"+Constants.myName)){
        replied = true;
      }
      if(!reply["open"]){
        numOfReplies ++;
      }
    }
    return GestureDetector(
      onLongPress: (){
        isSendByMe ? showMenu(
            context: context,
            position: RelativeRect.fromLTRB(0.0, MediaQuery.of(context).size.height, 0.0, 0.0),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                value:1,
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      Text("Delete")
                    ],
                  )),
            ]).then((value) {
              if(value == null){
                return;
              }else{
                deleteMessage(messageId);
              }
        }) : showMenu(
            context: context,
            position: RelativeRect.fromLTRB(0.0, MediaQuery.of(context).size.height, 0.0, 0.0),
            items: [
              PopupMenuItem(
                value: 1,
                  child: Row(
                    children: [
                      Icon(!replied ? Icons.reply : Icons.close),
                      Text(!replied ? "Reply" : "Replied")
                    ],
                  )
              )
            ]).then((value){
              if(value == null){
                return;
              }else{
                !replied ? showReplyBox(userId, sendBy, message, dateTime, time, imgObj, messageId ) : null;
              }
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: isSendByMe ? 24 : 8, right: isSendByMe ? 8 : 24),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: imgObj == null ? EdgeInsets.symmetric(horizontal: 24, vertical: 16) :
            EdgeInsets.symmetric(horizontal: 8, vertical: 8),

            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSendByMe ? [
                    const Color(0xffff914d),
                    const Color(0xffff914d)
                  ]:
                  [
                    const Color(0xffe5e7e9),
                    const Color(0xffe5e7e9),
                  ],
                ),
                borderRadius: isSendByMe ?
                BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23)
                ):
                BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)
                )

            ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !isSendByMe ? Container(
                    margin: EdgeInsets.fromLTRB(0.0,5.0,0.0,10.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: sendBy+" ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w300
                            )
                          ),
                          userId + "_" + sendBy == admin ? WidgetSpan(
                            child: Icon(Icons.circle, size: 14, color: Colors.orange,),
                          ) : TextSpan(),
                        ]
                      ),
                    ),
                  ) : SizedBox.shrink(),
                message != '' ? DynamicTextHighlighting(
                  text: message,
                  highlights: highlightWords,
                  color: Colors.blueAccent,
                  style: TextStyle(
                      color: isSendByMe ? Colors.white : Colors.black,
                      fontSize: 20
                  ),
                  caseSensitive: false,
                ) : FullScreenWidget(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                              imgObj['imgUrl'],
                              fit: BoxFit.cover
                          ),
                        ),
                      ),
                    ),
                  )

                ),
                imgObj != null ? imgObj['caption'].isNotEmpty ?
                Container(
                  margin: EdgeInsets.fromLTRB(0.0,10.0,10.0,10.0),
                  child: DynamicTextHighlighting(
                    text: imgObj['caption'],
                    highlights: highlightWords,
                    color: Colors.blueAccent,
                    style: TextStyle(
                        color: isSendByMe ? Colors.white : Colors.black,
                        fontSize: 20
                    ),
                    caseSensitive: false,
                  ),
                ) : SizedBox.shrink() : SizedBox.shrink(),

                isSendByMe ? numOfReplies > 0 ? GestureDetector(
                  onTap: (){
                    showRepliedUsers(replies, messageId, widget.groupChatId, context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white,
                          width: 3.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    margin: EdgeInsets.fromLTRB(0.0,10.0,10.0,0.0),
                    child: Text(
                      numOfReplies > 1 ? numOfReplies.toString() + " users replied" : numOfReplies.toString() + " user replied",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ):SizedBox.shrink() : SizedBox.shrink()
              ],
            )
        ),
      ),
    );
  }


  Widget chatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          reverse: true,
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
            return messageTile(snapshot.data.docs[index].data()["message"],
                snapshot.data.docs[index].data()["imgObj"],
                snapshot.data.docs[index].data()["sendBy"],
                snapshot.data.docs[index].data()["dateTime"],
                snapshot.data.docs[index].data()["time"],
                snapshot.data.docs[index].data()["userId"],
                snapshot.data.docs[index].data()["sendBy"] == Constants.myName,
                snapshot.data.docs[index].id,
                widget.admin,
                snapshot.data.docs[index].data()['replies']
            );
            }) : Container();
      },
    );
  }

  Future getImage() async {
    var pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    if(pickedImage != null){
      return File(pickedImage.path);
    }else{
      return null;
    }

  }

  sendImage(Map imgObj) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(now);

    DatabaseMethods(uid: widget.uid).addConversationMessages(widget.groupChatId, widget.hashTag, '',
        Constants.myName, formattedDate, now.microsecondsSinceEpoch, imgObj);
    DatabaseMethods(uid: widget.uid).addNotification(widget.groupChatId, widget.hashTag);

  }

  Future uploadImage() async {
    final File imgFile = await getImage();
    if(imgFile != null){
      String fileName = Path.basename(imgFile.path);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('groupChats/${widget.uid}_${Constants.myName}/$fileName');

      ref.putFile(imgFile).then((value){
        value.ref.getDownloadURL().then((val){
          sendImage({"imgUrl":val, "imgName":fileName,"imgPath":imgFile.path, "caption":""});
        });
      });
    }

  }

  _buildMessageComposer(){
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
                uploadImage();
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AppCameraScreen(Constants.myUserId, "", widget.groupChatId, widget.hashTag)));
            },
          ),
          Expanded(child: TextField(
            maxLines: null,
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration.collapsed(
              hintText: 'Message',
            ),
          ),),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget searchKeyWordBar(){
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
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
          SizedBox(width: 15,),
          Expanded(child: TextField(
            onChanged: (String val){
              if(val != ""){
                List<String> newHighlight = [val];
                setState(() {
                  highlightWords = newHighlight;
                });
              }else{
                setState(() {
                  highlightWords = [];
                });
              }
            },

            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintStyle: TextStyle(
                    color: Colors.white54
                ),
            ),
          )),
        ],
      ),
    );
  }

  showReplyBox(String userId, String userName, String text, String dateTime, int sendTime, Map imgMap, String messageId){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Message"),
            content: Form(
              key: formKey,
              child: Container(
                child: TextFormField(
                  autofocus: true,
                  validator: (val){
                    return val.isEmpty ? "Sorry, the reply message can not be empty" : null;
                  },
                  controller: replyEditingController,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed:(){
                    replyMessage(userId, userName, text, dateTime, sendTime, imgMap, messageId);
                  },
                  child: Text("SEND")
              ),
              FlatButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                  },
                  child: Text("CANCEL")
              )
            ],
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DatabaseMethods(uid: widget.uid).closeChat(widget.groupChatId, widget.hashTag);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: (){
                  setState(() {
                    searchKeyWord = !searchKeyWord;
                    highlightWords = [];
                  });
                },
              ),
              !widget.spectate ? IconButton(
                  icon: widget.admin == widget.uid + "_" + Constants.myName ? Icon(Icons.add): Icon(Icons.more_horiz),
                  iconSize: 30.0,
                  color: Colors.white,
                  onPressed: (){
                    widget.admin == widget.uid + "_" + Constants.myName ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) => InviteUserScreen(widget.groupChatId, widget.uid, widget.hashTag)
                    )) : Navigator.push(context, MaterialPageRoute(
                        builder: (context) => GroupChatSettingsScreen(widget.groupChatId, widget.uid, widget.hashTag)));
                  },
              ) : SizedBox.shrink()
            ],
            title: Text(widget.hashTag,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),),

          ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          onDoubleTap: (){
            setState(() {
              searchKeyWord = false;
              highlightWords = [];
            });
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              searchKeyWord ? searchKeyWordBar(): SizedBox.shrink(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: chatMessageList(),
                ),
              ),
              !widget.spectate ? _buildMessageComposer() : SizedBox.shrink(),
            ],
          ),
        )
      ),
    );
  }
}




