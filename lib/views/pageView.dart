import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/views/camera.dart';
import 'package:SpidrApp/views/chatRoomsScreen.dart';
import 'package:SpidrApp/views/feedPage.dart';
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
        AppCameraScreen(uid, "", ""),
        FeedPageScreen(),
      ],
    );
  }
}
