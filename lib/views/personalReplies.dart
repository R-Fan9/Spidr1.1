import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/personalChatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonalRepliesScreen extends StatefulWidget {
  @override
  _PersonalRepliesScreenState createState() => _PersonalRepliesScreenState();
}

class _PersonalRepliesScreenState extends State<PersonalRepliesScreen> {
  List personContacts = [];

  getUserContacts(){
    DatabaseMethods(uid: Constants.myUserId).getUserById().then((val){
      setState(() {
        personContacts = val.data()["personalChats"];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserContacts();
    super.initState();
  }

  removeContact(String personalChatId, String contactInfo){
    DatabaseMethods(uid: Constants.myUserId).deletePersonalChat(personalChatId, contactInfo).then((val){
      setState(() {
        personContacts = val;
      });
    });
  }

  Widget contactTile(String contactInfo, String personalChatId, bool openByOther){
    String contactName = contactInfo.substring(contactInfo.indexOf('_')+1);
    String contactId = contactInfo.substring(0, contactInfo.indexOf('_'));

    return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => PersonalChatScreen(personalChatId, contactName, contactId, openByOther)
          ));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white,
                      width: 3.0
                  ),
                    borderRadius: BorderRadius.circular(40),

                ),
                child: Text("${contactName.substring(0,1).toUpperCase()}",style:TextStyle(color:Colors.white),),
              ),
              SizedBox(width: 8,),
              Text("@ " + contactName, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
              Spacer(),
              GestureDetector(
                onTap: (){
                  removeContact(personalChatId, contactInfo);
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text("Remove", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                ),
              )
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Image.asset("assets/images/SpidrLogo.png", height: 50,),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                margin: EdgeInsets.all(15.0),
                child: Text("Personal Replies", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),)
            ),
            Expanded(
              child: ListView.builder(
                itemCount: personContacts.length,
                  itemBuilder: (context, index){
                  String contactInfo = personContacts[index].keys.elementAt(0);
                  String personalChatId = personContacts[index][contactInfo];
                  return contactTile(contactInfo, personalChatId, personContacts[index]['openByOther']);
                  }),
            )
          ],
        ),
      ),
    );
  }
}
