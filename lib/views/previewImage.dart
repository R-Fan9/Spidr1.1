import 'dart:io';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/createChatRoom.dart';
import 'package:SpidrApp/views/search.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart'as Path;


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
  TextEditingController captionEditingController = new TextEditingController();

  bool addCaption = false;

  final formKey = GlobalKey<FormState>();

  tagGroupChats(){
    if(formKey.currentState.validate()){
      String hashTag = hashTagEditingController.text;
      String caption = captionEditingController.text;
      DatabaseMethods(uid: widget.uid).tagGroupChats(hashTag.toUpperCase()).then((val){
        if(!val.docs.isEmpty){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen(widget.uid, hashTag, {"imgFile":imgFile, "imgName":Path.basename(widget.imgPath), "caption": caption})
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
                      alignment: Alignment.center,
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.black,
                              child: TextFormField(
                                autofocus: true,
                                validator: (val){
                                  return val.isEmpty ? "Sorry invalid hashtag" : null;
                                },
                                controller: hashTagEditingController,
                                style: TextStyle(color: Colors.orange, fontSize: 20),
                                decoration: InputDecoration(
                                  icon: Icon(Icons.tag, color: Colors.orange,),
                                ),
                              ),
                            ),
                            addCaption ? Container(
                              color: Colors.white70,
                              child: TextFormField(
                                maxLines: null,
                                validator: (val){
                                  return val.isEmpty ? "Sorry invalid caption" : null;
                                },
                                controller: captionEditingController,
                                style: TextStyle(color: Colors.black, fontSize: 20),
                                decoration: InputDecoration(
                                  icon: Icon(Icons.mode_outlined, color: Colors.black,),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black)
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black)
                                    )
                                ),
                              ),
                            ) : SizedBox.shrink(),

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
        ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,

        children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(Icons.mode_outlined),
            onPressed: (){
              setState(() {
                addCaption = !addCaption;
              });
              if(!addCaption){
                captionEditingController.text = "";
              }
            },
          ),
        ],
      ),
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
