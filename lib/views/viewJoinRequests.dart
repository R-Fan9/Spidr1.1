import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';

class JoinRequestsScreen extends StatefulWidget {
  final List<dynamic> joinRequestsList;
  final String groupId;
  final String hashTag;

  JoinRequestsScreen(this.joinRequestsList, this.groupId, this.hashTag);
  @override
  _JoinRequestsScreenState createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends State<JoinRequestsScreen> {

  List<dynamic> listOfRequests;

  acceptRequest(String groupId, String userInfo, String hashTag, String userId){
    DatabaseMethods(uid: userId).toggleGroupMembership(groupId, userInfo, hashTag, "ACCEPT_JOIN_REQ").then((val) {
      setState(() {
        listOfRequests = val;
      });
    });
  }

  declineRequest(String groupId, String userInfo, String userId){
    DatabaseMethods(uid: userId).declineJoinRequest(groupId, userInfo).then((val) {
      setState(() {
        listOfRequests = val;
      });
    });
  }

  Widget joinRequestTile(String groupId, String hashTag, String userId, String userInfo){
    String userName = userInfo.substring(userInfo.indexOf('_')+1);
    String userEmail = userInfo.substring(0, userInfo.indexOf('_'));

    return Container(
      color: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: simpleTextStyle(),),

                Text(userEmail, style: simpleTextStyle(),),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: (){
                declineRequest(groupId, userInfo, userId);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Icon(Icons.close)
              ),
            ),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                acceptRequest(groupId, userInfo, hashTag, userId);
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Icon(Icons.check)
              ),
            )
          ],
        )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      listOfRequests = widget.joinRequestsList;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Expanded(child: ListView.builder(
              itemCount: listOfRequests.length,
                itemBuilder: (context, index){
                String userInfo = listOfRequests[index];
                String userId = userInfo.substring(0, userInfo.indexOf('_'));
                String emailAndUsername = userInfo.substring(userInfo.indexOf('_') + 1);
                return joinRequestTile(
                    widget.groupId,
                    widget.hashTag,
                    userId,
                    emailAndUsername
                );
                }))
          ],
        ),
      ),
    );
  }
}

