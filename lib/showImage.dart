import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageShow extends StatefulWidget {
  Uint8List list;
  ImageShow({required this.list});

  @override
  _ImageShowState createState() => _ImageShowState();
}

class _ImageShowState extends State<ImageShow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.memory(widget.list),
    );
  }
}
