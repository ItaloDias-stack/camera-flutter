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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
          onSave(File(picture.path));
        },
        child: const Icon(
          Icons.download,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: MediaQuery.of(context).size.height - 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: FileImage(
                    File(picture.path),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
