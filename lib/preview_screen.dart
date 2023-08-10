import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  final File picture;
  final Function(File picture) onSave;
  final CameraController controller;
  const PreviewScreen(
      {super.key,
      required this.picture,
      required this.onSave,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      File(picture.path),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .2,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(.2),
                      radius: 30,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      onSave(File(picture.path));
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
