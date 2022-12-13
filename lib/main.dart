import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    super.initState();

    controller = CameraController(
      _cameras[1],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  List<int> temp = [];
  List<int> list = [];
  bool loading = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          floatingActionButton: list.length > 0
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      list.clear();
                      temp.clear();
                    });
                  },
                  child: Icon(Icons.cancel),
                )
              : FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    controller.takePicture().then((value) {
                      setState(() {
                        temp.clear();
                        temp.addAll(File(value.path).readAsBytesSync());
                      });
                    }).then((value) {
                      screenshotController
                          .captureFromWidget(Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment(0, -0.4),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: Container(
                                  height: 100,
                                  width: 60,
                                  child:
                                      Image.memory(Uint8List.fromList(temp))),
                            ),
                          ),
                          Image.asset("assets/img2.png", fit: BoxFit.fill),
                        ],
                      ))
                          .then((value) {
                        setState(() {
                          list.clear();
                          list.addAll(value);
                          print(list.length);
                          loading = false;
                        });
                      });
                    });
                  },
                  child: Icon(Icons.camera)),
          body: list.length > 0
              ? Image.memory(
                  Uint8List.fromList(list),
                  fit: BoxFit.fill,
                )
              : Center(
                  child: Screenshot(
                    controller: screenshotController,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment(0, -0.4),
                          child: Container(
                              height: 100,
                              width: 60,
                              child: CameraPreview(controller)),
                        ),
                        Image.asset("assets/img2.png", fit: BoxFit.fill),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
