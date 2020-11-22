import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
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

  createChatAndStartConvo() {
    if(formKey.currentState.validate()){
      String chatRoomState;
      if(state == 1){
        chatRoomState = "public";
      }else{
        chatRoomState = "private";
      }
      String hashTag = "#" + hashTagController.text;
      DateTime now = DateTime.now();

      List<String> searchKeys = [];
      String temp = "";
      for(int i = 0; i < hashTagController.text.length; i++){
        temp = temp + hashTagController.text[i];
        searchKeys.add(temp);
      }

      DatabaseMethods(uid: widget.uid).createChatRoom(hashTag.toUpperCase(), Constants.myName, chatRoomState, now.microsecondsSinceEpoch, searchKeys).then((groupChatId) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(groupChatId, hashTag.toUpperCase(), widget.uid + "_"+ Constants.myName, widget.uid)
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarMain(context),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: Colors.black),
                      controller: hashTagController,
                      decoration: InputDecoration(
                        hintText: "#Groupchat",
                        labelText: "Group Name",
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
              SizedBox(height: 16,),
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
              SizedBox(height:8,),
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
    );
  }
}
