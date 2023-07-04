import 'dart:developer';

import 'package:camera_test/camera_screen.dart';
import 'package:camera_test/custom_file_picker.dart';
import 'package:camera_test/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                pushToCameraScreen(
                  context: context,
                  onFileAdded: (file) {
                    log("Caminho do arquivo:$file");
                  },
                );
              },
              child: const Text("Abrir câmera"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pushToPlayerScreen(
                  context: context,
                  movieUrl:
                      "https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/example/9th_may_compressed.mp4?raw=true",
                  onExit: () {},
                  onBackground: () {},
                  seekOnInit: const Duration(seconds: 15),
                  secondaryColor: Colors.green,
                  primaryColor: Colors.yellow,
                  playerHeader: Container(
                    width: 60,
                    height: 60,
                    color: Colors.transparent,
                  ),
                );
              },
              child: const Text("Abrir player"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilepickerScreen(),
                  ),
                );
              },
              child: const Text("Abrir o file picker"),
            ),
          ],
        ),
      ),
    );
  }
}
