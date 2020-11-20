import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/camera.dart';
import 'package:chat_app/views/pageView.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();

  final formKey = GlobalKey<FormState>();

  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  signMeUp(){
    if(formKey.currentState.validate()){
      Map<String, dynamic> userInfoMap = {
        'name': userNameTextEditingController.text,
        'email': emailTextEditingController.text,
        'password': passwordTextEditingController.text,
        'myChats':[],
        'joinedChats':[]
      };

      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);

      setState(() {
        isLoading = true;
      });
      authMethods.signUpWithEmailAndPassword(emailTextEditingController.text,
          passwordTextEditingController.text).then((val){
        DatabaseMethods(uid: val.uid).uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => PageViewScreen(0)
            ));
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white ,

        body: isLoading ? Container(

          child: Center(child: CircularProgressIndicator()),
        ) : SingleChildScrollView(

          child: Container(

            height: MediaQuery.of(context).size.height - 50,
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        new Image.asset(
                          'assets/images/Spidrstart.png',
                          width: 240.0,
                          height: 240.0,
                          fit: BoxFit.cover,
                        ),
                        TextFormField(
                          validator: (val){
                            return val.isEmpty ? "Sorry, username's taken" : null;
                          },
                          controller: userNameTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter a Username",
                            labelText: "Username",
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
                          validator: (val){
                            return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Please provide a valid email";
                          },
                          controller: emailTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter an email",
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
                            return val.length > 6 ? null : "Password is not valid";
                          },
                          controller: passwordTextEditingController,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                            hintText: "Enter a Password",
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
                      ],
                    ),
                  ),
                  SizedBox(height:10,),
                  GestureDetector(
                    onTap: (){
                      signMeUp();
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
                      child: Text("Sign Up", style: simpleTextStyle(),),
                    ),
                  ),
                  SizedBox(height:8,),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Text("Sign Up with Google", style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    )),
                  ),
                  SizedBox(height:8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
                      GestureDetector(
                        onTap: (){
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Text(" Log in now", style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              decoration: TextDecoration.underline
                          ),),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height:50,),

                ],
              ),
            ),
          ),
        )

    );
  }
}
