import 'package:SpidrApp/helper/helperFunctions.dart';
import 'package:SpidrApp/model/chatUser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ChatUser _userFromFirebaseUser(User user){
    return user != null ? ChatUser(uid: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User firebaseUser = result.user;

      return _userFromFirebaseUser(firebaseUser);
    }catch(e){
      print(e.toString());
    }
  }

  Future resetPass(String email) async {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }

  Future signOut() async{
    try{
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserNameSharedPreference('');
      await HelperFunctions.saveUserEmailSharedPreference('');
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }
}