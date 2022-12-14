import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
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
          floatingActionButton: list.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      list.clear();
                      temp.clear();
                    });
                  },
                  child: const Icon(Icons.cancel),
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
                            alignment: const Alignment(0, -0.4),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: SizedBox(
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
                        var data = value;
                        // var image = base64Encode(data);
                        File fileImage = File.fromRawPath(data);
                        log("image--->$fileImage");
                        setState(() {
                          list.clear();
                          list.addAll(value);
                          print(list.length);
                          loading = false;
                        });
                        getFrmaImage(fileImage.toString());
                      });
                    });
                  },
                  child: const Icon(Icons.camera)),
          body: list.isNotEmpty
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
                          alignment: const Alignment(0, -0.4),
                          child: SizedBox(
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

  //------------- API CALL------------------//

  String imageUrl = '';
  Future getFrmaImage(String dataValue) async {
    var url = "https://dev.techstreet.in/frame/public/api/frameImage";
    var data = {
      // "frame": dataValue.toString(),
    };
    // var response = await http.post(Uri.parse(url), body: data);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    // request.fields.addAll(data);
    var response = await request.send();

    log("body=====>$data");

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    if (dataValue.toString().isNotEmpty) {
      var pic = await http.MultipartFile.fromPath(
        'frame',
        dataValue,
      );
      request.files.add(pic);
      log("Done====>  $pic");
    } else {
      log("ENTETED====> aa $dataValue");
    }

    log("Requests--->$request");
    log("PostResponse----> $responseString");
    log("StatusCodePost---->${response.statusCode}");
    log("response---->$response");
    log("responseData---->$responseData");

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      var result = jsonDecode(responseString);

      log("response--->$result");

      if (result['success'] == true) {
        setState(() {
          imageUrl = result['data'];
          log("image url--->$imageUrl");
        });
      } else {
        log(result['errors']);
      }
    } else {
      log("something went wrong !!");
    }
  }
}
