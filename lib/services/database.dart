import 'package:SpidrApp/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class DatabaseMethods{

  final String uid;
  DatabaseMethods({
    this.uid
  });

  final CollectionReference groupChatCollection = FirebaseFirestore.instance.collection('groupChats');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference personalChatCollection = FirebaseFirestore.instance.collection('personalChats');


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

  getUserById() async{
    return await userCollection
        .doc(uid)
        .get();
  }

  uploadUserInfo(userMap) async{
    return await userCollection
    .doc(uid)
    .set(userMap);
  }

  addPersonalMessage(String personalChatId, String text, String userName, String formattedDate, int sendTime, Map imgMap){
    personalChatCollection.doc(personalChatId)
        .collection("messages")
        .add({
      'text': text,
      'sender':userName,
      'senderId': uid,
      'formattedDateTime': formattedDate,
      'sendTime':sendTime,
      'imgMap': imgMap
    }).catchError((e) {print(e.toString());});

  }

  deletePersonalMessage(String personalChatId, String textId){
    personalChatCollection
        .doc(personalChatId)
        .collection("messages")
        .doc(textId)
        .delete();

    return getPersonMessages(personalChatId);
  }

  deletePersonalChat(String personalChatId, String contactInfo) async{
    String contactId = contactInfo.substring(0,contactInfo.indexOf("_"));

    DocumentReference contactDocRef = userCollection.doc(contactId);
    DocumentSnapshot contactSnapshot = await contactDocRef.get();
    List contactPerChats = contactSnapshot.data()["personalChats"];

    bool notOpenOrDeleted = true;
    for (int i = 0; i < contactPerChats.length ; i++){
      if(contactPerChats[i].containsKey(uid+"_"+Constants.myName)){
        if(contactPerChats[i][uid+"_"+Constants.myName] == personalChatId){
          notOpenOrDeleted  = false;
          break;
        }
      }
    }

    DocumentReference myDocRef = userCollection.doc(uid);
    DocumentSnapshot mySnapshot = await myDocRef.get();
    List myPerChats = mySnapshot.data()["personalChats"];
    int index;
    for (int i = 0; i < myPerChats.length ; i++){
      if(myPerChats[i].containsKey(contactInfo)){
        if(myPerChats[i][contactInfo] == personalChatId){
          index = i;
          break;
        }
      }
    }

    myPerChats.removeAt(index);
    await myDocRef.update({"personalChats":myPerChats});

    if(!notOpenOrDeleted){
      return myPerChats;
    }else{
      DocumentReference perChatDocRef = personalChatCollection.doc(personalChatId);
      DocumentSnapshot perChatSnapshot = await perChatDocRef.get();

      String groupId = perChatSnapshot.data()['originalGroupId'];
      String chatId = perChatSnapshot.data()['originalChatId'];

      updateConversationMessages(groupId, chatId, personalChatId, "", "DELETE_REPLY");

      return myPerChats;
    }

  }



  createPersonalChat(String userId, String userName, String text,
      String dateTime, int sendTime, Map imgMap, Map reply, String groupId, String messageId) async{
    DocumentReference perChatDocRef = await personalChatCollection.add({
      'to':userId+"_"+userName,
      'from':uid+"_"+Constants.myName,
      'originalChatId': messageId,
      'originalGroupId': groupId
    });

    await perChatDocRef.collection("messages")
        .add({
      'text': text,
      'sender':userName,
      'senderId': userId,
      'formattedDateTime': dateTime,
      'sendTime':sendTime,
      'imgMap': imgMap
    }).catchError((e) {print(e.toString());});
    if(reply != null){
      await perChatDocRef.collection("messages")
          .add(reply).catchError((e) {print(e.toString());});
    }


    await userCollection.doc(uid).update({"personalChats":
    FieldValue.arrayUnion([{userId+"_"+userName : perChatDocRef.id, "openByOther":false}])
    });

    return perChatDocRef.id;

  }

  Future<String> createGroupChat(String hashTag, String username, String chatRoomState, int time, List searchKeys, double groupCapacity) async{

    DocumentReference groupChatDocRef = await groupChatCollection.add({
      'hashTag': hashTag,
      'admin': uid + '_' + username,
      'members':[],
      'groupId': '',
      'chatRoomState': chatRoomState,
      'createdAt':time,
      'searchKeys':searchKeys,
      'joinRequests':[],
      'waitList':[],
      'groupCapacity':groupCapacity
    });

    await groupChatDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + username]),
      'groupId': groupChatDocRef.id
    });

    DocumentReference userDocRef = userCollection.doc(uid);
    await userDocRef.update({
      'myChats': FieldValue.arrayUnion([groupChatDocRef.id + '_' + hashTag + '_'+ uid + '_' + username])
    });

    return groupChatDocRef.id;

  }

  updateConversationMessages(String groupChatId, String messageId, String personalChatId, String userInfo, String actonType) async{
    DocumentReference chatDocRef = groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .doc(messageId);

    switch(actonType){
      case "ADD_REPLY":
        {
          await chatDocRef
              .update({
            "replies": FieldValue.arrayUnion(
                [{userInfo: personalChatId, "open": false}])
          });
        }
      break;

      case "OPEN_REPLY":
        {
          String userId = userInfo.substring(0, userInfo.indexOf('_'));
          DocumentReference userDocRef = userCollection.doc(userId);
          DocumentSnapshot userSnapshot = await userDocRef.get();
          List personalChats = userSnapshot.data()['personalChats'];

          for(var i in personalChats){
            if(i.containsKey(uid + "_" + Constants.myName)){
              if(i[i.keys.elementAt(0)] == personalChatId){
                i["openByOther"] = true;
                break;
              }
            }
          }

          await userDocRef.update({"personalChats":personalChats});

          DocumentSnapshot chatSnapshot = await chatDocRef.get();
          List replies = chatSnapshot.data()["replies"];

          for (Map reply in replies) {
            if (reply.containsKey(userInfo)) {
              reply["open"] = true;
              break;
            }
          }
          await chatDocRef
              .update({"replies": replies});

          await userCollection.doc(uid).update({
            "personalChats": FieldValue.arrayUnion([{userInfo: personalChatId, "openByOther":true}])
          });
        }
        break;

        case "DELETE_REPLY":
          {
            DocumentSnapshot chatSnapshot = await chatDocRef.get();

            List replies = chatSnapshot.data()['replies'];
            int index;
            bool opened = true;
            for (int i = 0; i < replies.length; i++) {
              if (replies[i][replies[i].keys.elementAt(0)] == personalChatId) {
                if(replies[i]['open']){
                  index = i;
                  break;
                }else{
                  opened = false;
                  break;
                }
              }
            }

            if(opened){
              replies.removeAt(index);
              await chatDocRef.update({'replies': replies});
              await personalChatCollection.doc(personalChatId).collection('messages')
              .get().then((value) {
                for(DocumentSnapshot ds in value.docs){
                  ds.reference.delete();
                }
              });
              await personalChatCollection.doc(personalChatId).delete();
            }

          }
          break;
    }

  }

  deleteConversationMessages(String groupChatId, String messageId){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .doc(messageId)
        .delete();

    return getConversationMessages(groupChatId);
  }



  addConversationMessages(String groupChatId, String message, String username, String dateTime, int time, Map imgObj){
    groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .add({
      'message': message,
      'sendBy': username,
      'userId': uid,
      'dateTime': dateTime,
      'time':time,
      'imgObj':imgObj,
      'replies':[]
    }).catchError((e) {print(e.toString());});
  }

  getConversationMessages(String groupChatId) async {
    return await groupChatCollection
        .doc(groupChatId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getPersonMessages(String personalChatId) async {
    return await personalChatCollection.doc(personalChatId)
        .collection("messages")
        .orderBy("sendTime", descending: true)
        .snapshots();
  }

  getMyChats(String username) async{
    return await groupChatCollection
        .where('members', arrayContains: uid + "_" + username)
        .snapshots();
  }

  getSpectatingChats(String username) async{
    return await groupChatCollection
        .where('waitList', arrayContains: uid + "_" + username)
        .snapshots();
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

  Future requestJoinGroup(String groupId, String username, String email, String search) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(!joinRequests.contains(uid + '_'+ email + '_' + username)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayUnion([uid + '_' + email + '_' + username])
      });
    }

    if(search.isNotEmpty){
      return searchGroupChats(search);
    }else{
      return getAllGroupChats();
    }
  }

  Future declineJoinRequest(String groupId, String userInfo) async{
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    List<dynamic> joinRequests = await groupDocSnapshot.data()['joinRequests'];
    if(joinRequests.contains(uid + '_' + userInfo)){
      await groupDocRef.update({
        'joinRequests': FieldValue.arrayRemove([uid + '_' + userInfo])
      });
    }

    return getJoinRequests(groupId);

  }

  Future joinGroupChat(DocumentReference userDocRef, DocumentReference groupDocRef, String groupId, String hashTag, String username, String admin) async {
    await userDocRef.update({
      'joinedChats': FieldValue.arrayUnion([groupId + '_' + hashTag + '_' + admin])
    });

    await groupDocRef.update({
      'members': FieldValue.arrayUnion([uid + '_' + username])
    });
  }

  Future putOnWaitList(String groupId, String username, String search) async {
    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();

    DocumentReference userDocRef = userCollection.doc(uid);

    List<dynamic> waitList = await groupDocSnapshot.data()['waitList'];
    if(!waitList.contains(uid + '_' + username)){
      await groupDocRef.update({
        'waitList': FieldValue.arrayUnion([uid + '_' + username])
      });
    }

    if(groupDocSnapshot.data()['chatRoomState'] == 'public'){
      String hashTag = groupDocSnapshot.data()['hashTag'];
      String admin = groupDocSnapshot.data()['admin'];

      await userDocRef.update({'spectating':FieldValue.arrayUnion([groupId+'_'+hashTag+'_'+admin])});
    }

    if(search.isNotEmpty){
      return searchGroupChats(search);
    }else{
      return getAllGroupChats();
    }
  }


  Future toggleGroupMembership(String groupId, String username, String hashTag, String actionType) async{
    DocumentReference userDocRef = userCollection.doc(uid);

    DocumentReference groupDocRef = groupChatCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await groupDocRef.get();
    String admin = groupDocSnapshot.data()['admin'];


    switch(actionType){
      case "JOIN_PUB_GROUP_CHAT":{
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username, admin);
      }
      break;
      case "LEAVE_GROUP":{
        List<dynamic> waitList = await groupDocSnapshot.data()['waitList'];
        String groupState = groupDocSnapshot.data()['chatRoomState'];
        await userDocRef.update({
          'joinedChats': FieldValue.arrayRemove([groupId + '_' + hashTag])
        });
        await groupDocRef.update({
          'members': FieldValue.arrayRemove([uid + '_' + username])
        });

        if(waitList.length > 0){

          String userId = waitList[0].substring(0, waitList[0].indexOf('_'));
          String userName = waitList[0].substring(waitList[0].indexOf('_')+1);

          DocumentReference userOnWLDocRef = userCollection.doc(userId);

          if(groupState == 'public'){
            await groupDocRef.update({
              'members': FieldValue.arrayUnion([userId + '_' + userName])
            });
            await userOnWLDocRef.update({
              'joinedChats': FieldValue.arrayUnion([groupId + '_' + hashTag])
            });
          }else{
            DocumentSnapshot userOnWLSnapshot = await userOnWLDocRef.get();
            await groupDocRef.update({
              'joinRequests': FieldValue.arrayUnion([userId + '_' + userOnWLSnapshot.data()['email'] + '_' + userName])
            });
          }

          await groupDocRef.update({
            'waitList': FieldValue.arrayRemove([userId + '_' + userName])
          });

        }

      }
      break;
      case "ACCEPT_JOIN_REQ":{
        await groupDocRef.update({
          'joinRequests': FieldValue.arrayRemove([uid + '_' + username])
        });
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username.substring(username.indexOf('_')+1), admin);
      }
      break;
      case "ADD_USER":{
        joinGroupChat(userDocRef, groupDocRef, groupId, hashTag, username, admin);
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