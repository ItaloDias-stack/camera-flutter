import 'package:camera_test/file_picker_player/file_picker_player.dart';
import 'package:flutter/material.dart';

showVideoDetails(String videoPath, BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    )),
    builder: (context) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 350,
          margin: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: FlickMultiPlayer(
              url: videoPath,
            ),
          ),
        ),
      );
    },
  );
}
