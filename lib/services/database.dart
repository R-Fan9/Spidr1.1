import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseMethods{

  final String uid;
  DatabaseMethods({
    this.uid
  });

  final CollectionReference groupChatCollection = FirebaseFirestore.instance.collection('groupChats');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  getUserByUsername(String username) async{
    return await userCollection
        .where("name", isEqualTo: username )
        .get();
  }

  getUserByUserEmail(String userEmail) async{
    return await userCollection
        .where("email", isEqualTo: userEmail )
        .get();
  }

  uploadUserInfo(userMap) async{
    return await userCollection
    .doc(uid)
    .set(userMap);
  }

  Future<String> createChatRoom(String hashTag, String username, String chatRoomState, int time, List searchKeys) async{

    DocumentReference groupChatDocRef = await groupChatCollection.add({
      'hashTag': hashTag,
      'admin': uid + '_' + username,
      'members':[],
      'groupId': '',
      'chatRoomState': chatRoomState,
      'createdAt':time,
      'searchKeys':searchKeys,
      'joinRequests':[],
    });

    await groupChatDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + username]),
      'groupId': groupChatDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    await userDocRef.update({
      'myChats': FieldValue.arrayUnion([{'groupId':groupChatDocRef.id, 'hashTag': hashTag}])
    });

    return groupChatDocRef.id;

  }

  deleteConversationMessages(String groupChatId, String messageId){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .doc(messageId)
        .delete();

    return getConversationMessages(groupChatId);
  }

  addConversationMessages(String groupChatId, String message, String username, String dateTime, int time, String imgUrl){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .add({
      'message': message,
      'sendBy': username,
      'userId': uid,
      'dateTime': dateTime,
      'time':time,
      'imgUrl':imgUrl
    }).catchError((e) {print(e.toString());});
  }

  getConversationMessages(String groupChatId) async {
    return await groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getMyChats(String username) async{
    return await groupChatCollection
        .where('members', arrayContains: uid + "_" + username).snapshots();
  }

  getGroupChatById(String groupId) async{
    return await groupChatCollection
        .doc(groupId).get();
  }

  getAllGroupChats() async{
    return await groupChatCollection.orderBy('createdAt', descending: true)
        .snapshots();
  }

  getAllUsers() async{
    return await userCollection.snapshots();
  }

  searchGroupChats(String searchText) async{
    return await groupChatCollection.where('searchKeys', arrayContains: searchText )
        .snapshots();
  }

  tagGroupChats(String searchText) async{
    return await groupChatCollection.where('searchKeys', arrayContains: searchText )
        .get();
  }

  getJoinRequests(String groupId) async {
    DocumentReference newGroupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot newGroupDocSnapshot = await newGroupDocRef.get();

    return newGroupDocSnapshot.data()['joinRequests'];
  }

  Future<String> isJoined(String groupId, String email) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    QuerySnapshot userSnapshot = await userCollection.where('email', isEqualTo: email).get();

    List<dynamic> members = await groupDocSnapshot.data()['members'];
    if(userSnapshot.docs.isNotEmpty){
      if(members.contains(userSnapshot.docs[0].id + '_' + userSnapshot.docs[0].data()['name'])){
        return "alreadyJoined";
      }else{
        return "notYetJoined";
      }
    }
    return "userDoesNotExist";

  }

  Future requestJoinGroup(String groupId, String username) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(!joinRequests.contains(uid + '_' + username)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayUnion([uid + '_' + username])
      });
    }

    return getAllGroupChats();
  }

  Future declineJoinRequest(String groupId, String username) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(joinRequests.contains(uid + '_' + username)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayRemove([uid + '_' + username])
      });
    }

    return getJoinRequests(groupId);

  }

  Future joinGroupChat(DocumentReference userDocRef, DocumentReference groupDocRef, String groupId, String hashTag, String username) async {
    await userDocRef.update({
      'joinedChats': FieldValue.arrayUnion([groupId + '_' + hashTag])
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + username])
    });
  }


  Future toggleGroupMembership(String groupId, String username, String hashTag, String actionType) async{
    DocumentReference userDocRef = userCollection.doc(uid);

    DocumentReference groupDocRef = groupChatCollection.doc(groupId);

    switch(actionType){
      case "JOIN_PUB_GROUP_CHAT":{
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username);
      }
      break;
      case "LEAVE_GROUP":{
        await userDocRef.update({
          'joinedChats': FieldValue.arrayRemove([groupId + '_' + hashTag])
        });
        await groupDocRef.update({
          'members': FieldValue.arrayRemove([uid + '_' + username])
        });
      }
      break;
      case "ACCEPT_JOIN_REQ":{
        await groupDocRef.update({
          'joinRequests': FieldValue.arrayRemove([uid + '_' + username])
        });
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username);
      }
      break;
      case "ADD_USER":{
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username);
        DocumentSnapshot userDocSnapshot = await userDocRef.get();
        return isJoined(groupId, userDocSnapshot.data()['email']);
      }
      break;
      default: {
        print('No such action');
      }
      break;

    }

    return getJoinRequests(groupId);

  }







}