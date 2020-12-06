import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/services/auth.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:SpidrApp/views/camera.dart';
import 'package:SpidrApp/views/pageView.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chatRoomsScreen.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  bool isLoading = false;

  QuerySnapshot snapshotUserInfo;

  signIn() async {
    if(formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      await authMethods.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text)
          .then((result) async {

        if(result != null) {
          QuerySnapshot userInfoSnapshot =
          await databaseMethods.getUserByUserEmail(emailTextEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0].data()["name"]
          );
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.docs[0].data()["Email"]
          );

          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => PageViewScreen(1)));
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white ,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(

            child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),

                child: Column(
                  children: [
                    Container(
                      child: new Image.asset(
                        'assets/images/SpidrStart.png',
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.width/2,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Form(
                      key: formKey,
                      child: Column(children: [
                        TextFormField(
                          validator: (val){
                            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Email is not registered :(";
                          },
                          controller: emailTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            labelText: "Email",
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
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val){
                            return val.length > 6 ? null : "Password incorrect :(";
                          },
                          controller: passwordTextEditingController,
                          style: TextStyle(color: Colors.black,),
                          cursorColor: Colors.orangeAccent,

                          decoration: InputDecoration(
                            hintText: "Enter your Password",
                            labelText: "Password",
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

                        ),
                      ],),
                    ),
                    SizedBox(height:8,),
                    Container(
                      alignment: Alignment.centerRight,
                      child:Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("Forgot your Password?", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),)
                      ),
                    ),
                    SizedBox(height:8,),
                    GestureDetector(
                      onTap: (){
                        signIn();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF9800),
                                  const Color(0xFFFF9800)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Text("Log In", style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                    SizedBox(height:8,),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.orange,
                              width: 3.0
                          ),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("Log In with Google", style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                        fontWeight: FontWeight.bold
                      )),
                    ),
                    SizedBox(height:8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold,),),
                        GestureDetector(
                          onTap: (){
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Text(" Join now ", style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                            ),),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
