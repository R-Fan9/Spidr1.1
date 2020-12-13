import 'dart:collection';
import 'dart:io';

import 'package:SpidrApp/helper/constants.dart';
import 'package:SpidrApp/services/database.dart';
import 'package:camera/camera.dart';
import 'package:SpidrApp/views/previewImage.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'as Path;


class CameraMethods{

  getCameraLensIcons(CameraLensDirection lensDirection){
    switch(lensDirection){
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }
  }

  onSwitchCamera(List cameras, int selectedCameraIndex, Function initCamera) {
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initCamera(selectedCamera);
  }


  onCaptureForChat(context, CameraController cameraController, String personalChatId, String groupChatId, String hashTag) async{
    try{
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures';
      await Directory(dirPath).create(recursive: true);
      final String imgName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final String filepath = '$dirPath/$imgName';

      await cameraController.takePicture(filepath).then((value) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(now);

        String fileName = Path.basename(filepath);

        Reference ref;

        if(personalChatId.isNotEmpty){
          ref = FirebaseStorage.instance
              .ref()
              .child('personalChats/${Constants.myUserId}_${Constants.myName}/$fileName');

          ref.putFile(File(filepath)).then((value){
            value.ref.getDownloadURL().then((val){

              DatabaseMethods(uid: Constants.myUserId).addPersonalMessage(personalChatId,
                  "", Constants.myName, formattedDate,
                  now.microsecondsSinceEpoch, {"imgUrl":val, "imgName": fileName, "imgPath":filepath, "caption":""});
            });
          });
        }else{
          ref = FirebaseStorage.instance
              .ref()
              .child('groupChats/${Constants.myUserId}_${Constants.myName}/$fileName');

          ref.putFile(File(filepath)).then((value){
            value.ref.getDownloadURL().then((val){
              DatabaseMethods(uid: Constants.myUserId).addConversationMessages(groupChatId, hashTag,
                  "", Constants.myName, formattedDate, now.microsecondsSinceEpoch,
                  {"imgUrl":val, "imgName": fileName, "imgPath":filepath, "caption":""});
              DatabaseMethods(uid: Constants.myUserId).addNotification(groupChatId, hashTag);
            });
          });
        }

        Navigator.of(context).pop();

      });

    } catch (e) {
      showCameraException(e);
    }
  }


  onCaptureForApp(context, CameraController cameraController, String uid) async{
    try{
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures';
      await Directory(dirPath).create(recursive: true);
      final String imgName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final String filepath = '$dirPath/$imgName';

      await cameraController.takePicture(filepath).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewImageScreen(filepath, uid)));

      });

    } catch (e) {
      showCameraException(e);
    }
  }


  showCameraException(e){
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }

}