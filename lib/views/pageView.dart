import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/views/camera.dart';
import 'package:chat_app/views/chatRoomsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  getUseInfo() async {
    User _user = await FirebaseAuth.instance.currentUser;
    Constants.myName = await HelperFunctions.getUserNameInSharedPreference();
    Constants.myUserId = _user.uid;
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
        AppCameraScreen(uid),
        ChatRoom()
      ],
    );
  }
}
