import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewPicture extends StatelessWidget {
  const PreviewPicture({
    super.key,
    required this.picture,
    required this.onPressed,
  });

  final XFile picture;
  final Function onPressed;

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: height * 0.8,
              width: size.width * 0.8,
              child: Image.file(
                File(picture.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 20),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height * 0.08 / size.aspectRatio),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RawMaterialButton(
                splashColor: Colors.grey,
                highlightColor: Colors.grey,
                shape: const CircleBorder(),
                elevation: 1.0,
                onPressed: () {
                  Navigator.pop(context);
                  onPressed();
                },
                child: Image.asset(
                  'assets/icon-send.png',
                  color: Colors.white,
                  package: 'flutter_chat_ui',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
