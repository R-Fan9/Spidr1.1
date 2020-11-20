import 'package:camera/camera.dart';
import 'package:chat_app/services/camera.dart';
import 'package:flutter/material.dart';

// App Bar Widget
Widget appBarMain(BuildContext context){
  return AppBar(
    title: Image.asset("assets/images/spidr_logo.jpg", height: 50,),
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
