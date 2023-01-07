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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Center(
                child: Image.file(
                  File(picture.path),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
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
        ],
      ),
    );
  }
}
