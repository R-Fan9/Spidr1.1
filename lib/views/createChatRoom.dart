import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/conversation_screen.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';

class CreateChatRoom extends StatefulWidget {
  final String uid;
  CreateChatRoom(this.uid);
  @override
  _CreateChatRoomState createState() => _CreateChatRoomState();
}

class _CreateChatRoomState extends State<CreateChatRoom> {
  TextEditingController hashTagController = new TextEditingController();

  final formKey = GlobalKey<FormState>();
  int state = 1;
  double groupCapacity = 2;

  createChatAndStartConvo() {
    String hashTag;
    if(formKey.currentState.validate()){
      String chatRoomState;
      if(state == 1){
        chatRoomState = "public";
      }else{
        chatRoomState = "private";
      }
      if(hashTagController.text.substring(0,1) != "#"){
        hashTag = "#" + hashTagController.text;
      }else{
        hashTag = hashTagController.text;
      }

      DateTime now = DateTime.now();

      List<String> searchKeys = [];
      String temp = "";
      for(int i = 0; i < hashTagController.text.length; i++){
        temp = temp + hashTagController.text[i].toUpperCase();
        searchKeys.add(temp);
      }

      DatabaseMethods(uid: widget.uid).createGroupChat(hashTag.toUpperCase(), Constants.myName, chatRoomState, now.microsecondsSinceEpoch, searchKeys, groupCapacity).then((groupChatId) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(groupChatId, hashTag.toUpperCase(), widget.uid + "_"+ Constants.myName, widget.uid, false, true)
        ));
      }, onError: (error){
        print(error);
      }
      );

      hashTagController.text = "";
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarMain(context),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),

        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 75,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/SpidrNet.png',
                      width: MediaQuery.of(context).size.width/5,
                      height: MediaQuery.of(context).size.width/5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(color: Colors.black),
                          controller: hashTagController,
                          decoration: InputDecoration(
                            hintText: "GROUPCHAT",
                            labelText: "Group Name",
                            icon: Icon(Icons.tag, color: Colors.orange),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                          validator: (val){
                            return val.isEmpty ? "Please enter a hashTag" : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      RadioListTile(
                        activeColor: Colors.orange,
                        value: 1,
                        groupValue: state,
                        title:Text("Public"),
                        onChanged: (T) {
                          setState(() {
                            state = T;
                          });
                        },
                      ),
                      RadioListTile(
                        activeColor: Colors.orange,
                        value: 2,
                        groupValue: state,
                        title: Text("Private"),
                        onChanged: (T) {
                          setState(() {
                            state = T;
                          });
                        },
                      ),
                    ],
                  ),
                  Slider(
                    activeColor: Colors.orange,
                      value: groupCapacity,
                      min: 1,
                      max: 6,
                      divisions: 5,
                    onChanged: (newCapacity){
                        setState(() {
                          groupCapacity = newCapacity;
                        });
                      },
                    label: "$groupCapacity",
                  ),
                  Text("Group Limit (50)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                  GestureDetector(
                    onTap: (){
                      createChatAndStartConvo();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.orange,

                              ]
                          ),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("Create Group Chat", style: simpleTextStyle(),),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
