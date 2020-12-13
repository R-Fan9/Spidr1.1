import 'dart:io';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart'as Path;


class PersonalChatScreen extends StatefulWidget {
  final String personalChatId;
  final String contactName;
  final String contactId;
  final bool openByOther;
  PersonalChatScreen(this.personalChatId, this.contactName, this.contactId, this.openByOther);
  @override
  _PersonalChatScreenState createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  Stream personalMessageStream;
  TextEditingController textController = new TextEditingController();
  bool chatExist;


  Future getImage() async {
    var pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

    if(pickedImage != null){
      return File(pickedImage.path);
    }else{
      return null;
    }

  }

  sendImage(Map imgMap) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(now);

    DatabaseMethods(uid: Constants.myUserId).addPersonalMessage(widget.personalChatId, '',
        Constants.myName, formattedDate, now.microsecondsSinceEpoch, imgMap);
  }

  Future uploadImage() async {
    final File imgFile = await getImage();
    if(imgFile != null){
      String fileName = Path.basename(imgFile.path);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('personalChats/${Constants.myUserId}_${Constants.myName}/$fileName');

      ref.putFile(imgFile).then((value){
        value.ref.getDownloadURL().then((val){
          sendImage({"imgUrl":val,"caption":""});
        });
      });
    }

  }

  // Check to if the chat has been deleted by the other user
  checkChatStatus() {
    bool chatNotDeleted = false;
    DatabaseMethods(uid: widget.contactId).getUserById().then((val){
      List personalChats = val.data()["personalChats"];
      for(var i in personalChats){
        if(i.containsKey(Constants.myUserId+'_'+Constants.myName)){
          if(i[Constants.myUserId+'_'+Constants.myName] == widget.personalChatId){
            chatNotDeleted = true;
            break;
          }
        }
      }
      setState(() {
        chatExist = chatNotDeleted;
      });
    });

  }


  @override
  void initState() {
    DatabaseMethods(uid: Constants.myUserId).getPersonMessages(widget.personalChatId).then((val){
      setState(() {
        personalMessageStream = val;
      });
    });
    widget.openByOther ? checkChatStatus() : null;
    // TODO: implement initState
    super.initState();
  }

  sendMessage(){
    if(textController.text.isNotEmpty){
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(now);

      DatabaseMethods(uid: Constants.myUserId).addPersonalMessage(widget.personalChatId, textController.text,
          Constants.myName, formattedDate, now.microsecondsSinceEpoch, null);
      textController.text = "";
    }
  }

  deleteMessage(String textId){
    DatabaseMethods(uid: Constants.myUserId).deletePersonalMessage(widget.personalChatId, textId).then((val){
      setState(() {
        personalMessageStream = val;
      });
    });
  }

  Widget textTile(String text, String dateTime, Map imgMap, bool isSendByMe, String textId){
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
            deleteMessage(textId);
          }
        }) : null;

      },
      child: Container(
        padding: EdgeInsets.only(left: isSendByMe ? 24 : 8, right: isSendByMe ? 8 : 24),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            padding: imgMap == null ? EdgeInsets.symmetric(horizontal: 24, vertical: 16) :
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text != '' ? Text(
                  text,
                  style: TextStyle(
                      color: isSendByMe ? Colors.white : Colors.black,
                      fontSize: 20
                  ),
                ) : FullScreenWidget(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                                imgMap['imgUrl'],
                                fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    )

                ),
                imgMap != null ? imgMap['caption'].isNotEmpty ?
                Container(
                  margin: EdgeInsets.fromLTRB(0.0,10.0,10.0,10.0),
                  child: Text(
                    imgMap['caption'],
                    style: TextStyle(
                        color: isSendByMe ? Colors.white : Colors.black,
                        fontSize: 20
                    ),
                  ),
                ) : SizedBox.shrink() : SizedBox.shrink(),
              ],
            )
        ),
      ),
    );
  }

  Widget textList(){
    return StreamBuilder(
      stream: personalMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return textTile(snapshot.data.docs[index].data()["text"],
                snapshot.data.docs[index].data()["formattedDateTime"],
                snapshot.data.docs[index].data()["imgMap"],
                snapshot.data.docs[index].data()["sender"] == Constants.myName,
                snapshot.data.docs[index].id
              );
            }) : Container();
      },
    );
  }

  messageComposer(){
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
                  builder: (context) => AppCameraScreen(Constants.myUserId, widget.personalChatId, "","")));
            },
          ),
          Expanded(child: TextField(
            maxLines: null,
            controller: textController,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.contactName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              chatExist != null ? !chatExist ?
                  Container(
                    height: 30.0,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(child: Icon(Icons.warning_amber_rounded, color: Colors.white,)),
                            TextSpan(text: widget.contactName + " has deleted this chat", style: TextStyle(color: Colors.white))
                          ]
                        )
                      ),
                    ),
                  ) : SizedBox.shrink() : SizedBox.shrink(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: textList(),
                ),
              ),
              messageComposer()
            ],
          ),
        )
    );
  }
}
