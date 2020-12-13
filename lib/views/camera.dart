import 'package:camera/camera.dart';
import 'package:SpidrApp/services/camera.dart';
import 'package:SpidrApp/widgets/widget.dart';
import 'package:flutter/material.dart';


class AppCameraScreen extends StatefulWidget {
  final String uid;
  final String personalChatId;
  final String groupChatId;
  final String hashTag;
  AppCameraScreen(this.uid, this.personalChatId, this.groupChatId, this.hashTag);

  @override
  _AppCameraScreenState createState() => _AppCameraScreenState();
}

class _AppCameraScreenState extends State<AppCameraScreen> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;

  Widget cameraPreview(){
    if(cameraController == null || !cameraController.value.isInitialized){
      return Text(
        'Loading',
        style: simpleTextStyle(),
      );
    }

    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }


  Future initCamera(CameraDescription cameraDescription) async{
    if(cameraController != null){
      await cameraController.dispose();
    }

    cameraController = CameraController(cameraDescription, ResolutionPreset.high);

    cameraController.addListener((){
      if(mounted){
        setState(() {
        });
      }
    });

    if(cameraController.value.hasError){
      print('Camera Error ${cameraController.value.errorDescription}');
    }

    try{
      await cameraController.initialize();
    }catch (e){
      CameraMethods().showCameraException(e);
    }

    if(mounted){
      setState(() {
      });
    }
  }

  Widget cameraToggle(){
    if(cameras == null || cameras.isEmpty){
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
              onPressed: (){
                int newCameraIndex =
                selectedCameraIndex == 0 ? 1 : 0;
                CameraMethods().onSwitchCamera(cameras, newCameraIndex, initCamera);
                setState(() {
                  selectedCameraIndex = newCameraIndex;
                });
              },
              icon: Icon(
                CameraMethods().getCameraLensIcons(lensDirection),
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              )),
        )
    );
  }

  Widget cameraControl(context){
    return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              FloatingActionButton(
                onPressed: (){
                  widget.personalChatId.isEmpty && widget.groupChatId.isEmpty ?
                  CameraMethods().onCaptureForApp(context, cameraController, widget.uid) :
                  CameraMethods().onCaptureForChat(context, cameraController, widget.personalChatId, widget.groupChatId, widget.hashTag);
                },
                backgroundColor: Colors.transparent,
                child: Icon(Icons.circle, color: Theme.of(context).primaryColor,),
              )
            ],
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: cameraPreview(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    cameraToggle(),
                    cameraControl(context),
                    Spacer()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availableCameras().then((value){
      cameras = value;
      if(cameras.length > 0){
        setState(() {
          selectedCameraIndex = 0;
        });
        initCamera(cameras[selectedCameraIndex]);
      } else {
        print("No camera available");
      }
    }).catchError((e){print('Error: ${e.code}');});
  }
}
