import 'dart:io';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/views/camera.dart';
import 'package:SpidrApp/views/chatRoomsScreen.dart';
import 'package:SpidrApp/views/feedPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PageViewScreen extends StatefulWidget {
  final int page;
  PageViewScreen(this.page);
  @override
  _PageViewScreenState createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  PageController pageController;
  int pageNumber;
  String uid;

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void registerNotification(String userId){
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
      onResume: (Map<String, dynamic> message){
        print('onResume: $message');
        return;
      },
      onLaunch: (Map<String, dynamic> message){
        print('onLaunch: $message');
        return;
      }
    );

    firebaseMessaging.getToken().then((token) async{

      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      DocumentSnapshot userSnapshot = await userDocRef.get();
      if(userSnapshot.data()['pushToken'] != token){

        userDocRef.update({'pushToken':token});

        List myChats = userSnapshot.data()['myChats'];
        List joinedChats = userSnapshot.data()['joinedChats'];

        for(String groupInfo in myChats){
          String groupId = groupInfo.substring(0,groupInfo.indexOf('_'));
          String hashTagAndAdmin = groupInfo.substring(groupInfo.indexOf('_')+1);
          String hashTag = hashTagAndAdmin.substring(0, hashTagAndAdmin.indexOf('_'));

          FirebaseFirestore.instance.collection('groupChat_users')
              .doc(groupId+'_'+hashTag)
              .collection('users')
              .doc(userId+'_'+Constants.myName).update({'token':token});
        }

        for(String groupInfo in joinedChats){
          String groupId = groupInfo.substring(0,groupInfo.indexOf('_'));
          String hashTagAndAdmin = groupInfo.substring(groupInfo.indexOf('_')+1);
          String hashTag = hashTagAndAdmin.substring(0, hashTagAndAdmin.indexOf('_'));

          FirebaseFirestore.instance.collection('groupChat_users')
              .doc(groupId+'_'+hashTag)
              .collection('users')
              .doc(userId+'_'+Constants.myName).update({'token':token});
        }
      }

    }).catchError((err){
      print(err.message.toString());
    });

  }


  getUseInfo() async {
    User _user = await FirebaseAuth.instance.currentUser;
    Constants.myName = await HelperFunctions.getUserNameInSharedPreference();
    Constants.myUserId = _user.uid;
    Constants.myEmail = _user.email;
    return _user;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUseInfo().then((val) {
      setState(() {
        uid = val.uid;
      });
      registerNotification(val.uid);
    });
    setState(() {
      pageNumber = widget.page;
    });
    pageController = PageController(initialPage: pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: [
        ChatRoom(),
        AppCameraScreen(uid, "", "", ""),
        FeedPageScreen(),
      ],
    );
  }
}
