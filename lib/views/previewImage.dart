import 'dart:io';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/createChatRoom.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class PreviewImageScreen extends StatefulWidget {
  final String imgPath;
  final String uid;
  PreviewImageScreen(this.imgPath, this.uid);

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}


class _PreviewImageScreenState extends State<PreviewImageScreen> {
  File imgFile;
  TextEditingController hashTagEditingController = new TextEditingController();

  final formKey = GlobalKey<FormState>();

  tagGroupChats(){
    if(formKey.currentState.validate()){
      String hashTag = hashTagEditingController.text;
      DatabaseMethods(uid: widget.uid).tagGroupChats(hashTag.toUpperCase()).then((val){
        if(!val.docs.isEmpty){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen(widget.uid, hashTag, imgFile)
          ));
        }else{
          showAlertDialog();
        }
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(imgFile), fit: BoxFit.cover
              )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (val){
                                return val.isEmpty ? "Sorry invalid hashtag" : null;
                              },
                              controller: hashTagEditingController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("#"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    color: Colors.transparent,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.double_arrow_sharp, color: Theme.of(context).primaryColor, size: 42,),
                        onPressed: () {
                          tagGroupChats();
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      imgFile = new File(widget.imgPath);
    });
  }

  void showAlertDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Oops"),
            content: Text("The group you are looking for doesn't exist yet. Do you want to create it?"),
            actions: [
              FlatButton(
                  onPressed:(){
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => CreateChatRoom(widget.uid)
                    ));
                  },
                  child: Text("CREATE")
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

}
