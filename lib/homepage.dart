// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:northeast_united_fc/qrcode.dart' as qrPage;
import 'package:northeast_united_fc/showImage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class CameraApp extends StatefulWidget {
  CameraDescription cameraDescription;
  CameraApp({Key? key, required this.cameraDescription}) : super(key: key);
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
      widget.cameraDescription,
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
      });
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
  bool loading = true;

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
          appBar: AppBar(
            title: Text("PLACE YOUR FACE"),
            centerTitle: true,
            backgroundColor: Colors.blue[800],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: const Alignment(0, -0.5),
                  child: SizedBox(
                      height: 100, width: 60, child: CameraPreview(controller)),
                ),
                Image.asset("assets/img2.png", fit: BoxFit.cover),
              ],
            ),
          ),
          bottomSheet: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: Colors.blue[800],
            child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            child: Container(
                              height: 120,
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/loader.gif",
                                    scale: 5,
                                  ),
                                  Text("Processing...")
                                ],
                              ),
                            ),
                          ));
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
                          alignment: const Alignment(0, -0.35),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: SizedBox(
                                height: 100,
                                width: 60,
                                child: Image.memory(Uint8List.fromList(temp))),
                          ),
                        ),
                        Image.asset("assets/img2.png", fit: BoxFit.fill),
                      ],
                    ))
                        .then((value) async {
                      Directory appDocDir =
                          await getApplicationDocumentsDirectory();
                      String appDocPath = appDocDir.path;
                      // var image = base64Encode(data);
                      File file = File(appDocPath + "/frame.jpeg");
                      file.writeAsBytesSync(value);
                      setState(() {
                        list.clear();
                        list.addAll(value);
                      });
                      print("file path: " + file.path.toString());
                      var URL =
                          "https://dev.techstreet.in/frame/public/api/frameImage";

                      var request =
                          http.MultipartRequest('POST', Uri.parse(URL));
                      request.files.add(http.MultipartFile('frame',
                          file.readAsBytes().asStream(), file.lengthSync(),
                          filename: "frame.jpeg"));
                      // request.headers
                      //     .addAll({'Content-Type': 'application/json'});
                      var res = await request.send();
                      var respStr = await res.stream.bytesToString();
                      print(res.statusCode);
                      print(respStr);
                      if (res.statusCode == 200) {
                        Navigator.of(context, rootNavigator: false).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => qrPage.QrCode(
                                    path: jsonDecode(respStr)['data']
                                        .toString()))).then((value) {
                          list.clear();
                          temp.clear();

                          loading = false;
                        });
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ImageShow(list: value)));
                      }
                    });
                  });
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue[800])),
                label: Text(
                  "CLICK",
                ),
                icon: Icon(Icons.camera)),
          ),
        ),
      ),
    );
  }
}
