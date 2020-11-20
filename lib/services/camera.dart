import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chat_app/views/previewImage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

  /*
  onCaptureForChat(context, CameraController cameraController, Map groupInfo) async{
    try{
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures';
      await Directory(dirPath).create(recursive: true);
      final String imgName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final String filepath = '$dirPath/$imgName';

      await cameraController.takePicture(filepath).then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewChatImageScreen(filepath,
            groupInfo['groupId'],
            groupInfo['uid'],
            groupInfo['hashTag'],
            groupInfo['admin'])));

      });

    } catch (e) {
      showCameraException(e);
    }
  }
   */

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