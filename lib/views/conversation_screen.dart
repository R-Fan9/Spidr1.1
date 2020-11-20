import 'dart:io';

import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/camera.dart';
import 'package:chat_app/views/groupChatSettings.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:dynamic_text_highlighting/dynamic_text_highlighting.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart'as Path;

import 'inviteUser.dart';

class ConversationScreen extends StatefulWidget {
  final String groupChatId;
  final String hashTag;
  final String admin;
  final String uid;
  ConversationScreen(this.groupChatId, this.hashTag, this.admin, this.uid);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageController = new TextEditingController();

  Stream chatMessageStream;
  List<String> highlightWords = [];
  bool searchKeyWord = false;

  @override
  void initState() {
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
      String formattedDate = DateFormat('kk:mm:a').format(now);

      DatabaseMethods(uid: widget.uid).addConversationMessages(widget.groupChatId, messageController.text, Constants.myName, formattedDate, now.microsecondsSinceEpoch, '');
      messageController.text = "";
    }
  }

  deleteMessage(String messageId){
    DatabaseMethods(uid: widget.uid).deleteConversationMessages(widget.groupChatId, messageId).then((val){
      setState(() {
        chatMessageStream = val;
      });
    });
  }

  Widget messageTile(message, imgUrl, sendBy, dateTime, userId, isSendByMe, messageId, admin){
    return GestureDetector(
      onLongPress: (){
        isSendByMe ? showMenu(
            context: context,
            position: RelativeRect.fromLTRB(0.0, 600.0, 300.0, 0.0),
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
        }) : null;
      },
      child: Container(
        padding: EdgeInsets.only(left: isSendByMe ? 24 : 8, right: isSendByMe ? 8 : 24),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),

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
                !isSendByMe ? Row(
                  children: [
                    Text(sendBy, style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w300
                    )),
                    SizedBox(width: 4,),
                    userId + "_" + sendBy == admin ? Container(
                      width: 10,
                      height: 10,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor
                      ),
                    ):SizedBox.shrink()
                  ],
                ) : SizedBox.shrink(),
                message != '' ? DynamicTextHighlighting(
                  text: message,
                  highlights: highlightWords,
                  color: Colors.orangeAccent,
                  style: TextStyle(
                      color: isSendByMe ? Colors.white : Colors.black,
                      fontSize: 20
                  ),
                  caseSensitive: false,
                ) : Card(
                    child: Column(
                      children: [
                        Container(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.cover
                            ),
                          ),
                        )
                      ],
                    ),
                )
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
            snapshot.data.docs[index].data()["imgUrl"],
            snapshot.data.docs[index].data()["sendBy"],
            snapshot.data.docs[index].data()["formattedDate"],
            snapshot.data.docs[index].data()["userId"],
            snapshot.data.docs[index].data()["sendBy"] == Constants.myName,
            snapshot.data.docs[index].id,
            widget.admin);
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

  sendImage(String imgUrl) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:a').format(now);

    DatabaseMethods(uid: widget.uid).addConversationMessages(widget.groupChatId, '', Constants.myName, formattedDate, now.microsecondsSinceEpoch, imgUrl);
  }

  Future uploadImage() async {
    final File imgFile = await getImage();
    if(imgFile != null){
      String fileName = Path.basename(imgFile.path);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.uid}_${Constants.myName}/$fileName');

      ref.putFile(imgFile).then((value){
        value.ref.getDownloadURL().then((val){
          sendImage(val);
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
          Expanded(child: TextField(
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            IconButton(
                icon: widget.admin == widget.uid + "_" + Constants.myName ? Icon(Icons.add): Icon(Icons.more_horiz),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: (){
                  widget.admin == widget.uid + "_" + Constants.myName ? Navigator.push(context, MaterialPageRoute(
                      builder: (context) => InviteUserScreen(widget.groupChatId, widget.uid, widget.hashTag)
                  )) : Navigator.push(context, MaterialPageRoute(
                      builder: (context) => GroupChatSettingsScreen(widget.groupChatId, widget.uid, widget.hashTag)));
                },
            )
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
            _buildMessageComposer(),
          ],
        ),
      )
    );
  }
}




