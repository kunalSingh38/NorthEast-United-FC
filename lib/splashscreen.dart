// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:northeast_united_fc/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () async {
      _cameras = await availableCameras();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CameraApp(
                    cameraDescription: _cameras[1],
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Image.asset(
                    "assets/loader.gif",
                    scale: 3,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "NorthEast United FC\nx\nImperial Blue",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            )),
      ),
    );
  }
}
