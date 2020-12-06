import 'package:camera/camera.dart';
import 'package:SpidrApp/services/camera.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/personalChatScreen.dart';
import 'package:SpidrApp/helper/constants.dart';
import 'package:flutter/material.dart';

// App Bar Widget
Widget appBarMain(BuildContext context){
  return AppBar(
    title: Image.asset("assets/images/SpidrLogo.png", height: 50,),
  );
}

// Input Field Widget
InputDecoration textFieldInputDecoration(String hintText){
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white54,
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
      )
  );
}


// Simple Text Widget
TextStyle simpleTextStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 16
  );
}


showRepliedUsers(List replies, String messageId, String groupId, BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.maxFinite,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: replies.length,
                  itemBuilder: (context, index){
                    String userInfo = replies[index].keys.elementAt(0);
                    String personalChatId = replies[index][userInfo];
                    bool opened = replies[index]["open"];
                    return !opened ? Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        child: GestureDetector(
                          onTap: () async{
                            await DatabaseMethods(uid: Constants.myUserId).updateConversationMessages(groupId, messageId, personalChatId, userInfo, "OPEN_REPLY");

                            Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => PersonalChatScreen(personalChatId, userInfo.substring(userInfo.indexOf('_')+1), userInfo.substring(0, userInfo.indexOf('_')), true)));
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            title: Text("From " + userInfo.substring(userInfo.indexOf('_')+1)),
                            trailing: Icon(Icons.keyboard_arrow_right, size: 30.0,),
                          ),
                        ),
                      ),
                    ) : SizedBox.shrink();
                  }
              ),
            ),
          ),
        );
      }
  );
}
