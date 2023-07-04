import 'dart:io';

import 'package:camera_test/camera_screen.dart';
import 'package:camera_test/image_details.dart';
import 'package:camera_test/misc.dart';
import 'package:camera_test/video_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loomi_ui_flutter/utils/custom_icons.dart';
import 'package:loomi_ui_flutter/widgets/custom_button.dart';
import 'package:loomi_ui_flutter/widgets/get_icon.dart';

class FilepickerScreen extends StatefulWidget {
  const FilepickerScreen({super.key});

  @override
  State<FilepickerScreen> createState() => _FilepickerScreenState();
}

class _FilepickerScreenState extends State<FilepickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomFilePicker(
              label: "Arquivos",
              onAdd: (file) {},
              limitOfFiles: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFilePicker extends StatefulWidget {
  final Function(File) onAdd;
  final Function(File)? onRemove;
  final List<File>? previousFiles;
  final String label;
  final Color? componentsColor;
  final bool showActions;
  final int limitOfFiles;
  const CustomFilePicker({
    super.key,
    required this.label,
    this.componentsColor,
    this.previousFiles,
    required this.onAdd,
    this.showActions = true,
    this.onRemove,
    required this.limitOfFiles,
  });

  @override
  State<CustomFilePicker> createState() => _CustomFilePickerState();
}

class _CustomFilePickerState extends State<CustomFilePicker> {
  List<File> files = [];
  List<File> compressedImageList = [];
  @override
  void initState() {
    if (widget.previousFiles != null) {
      for (var element in widget.previousFiles!) {
        files.add(element);
        compressedImageList.add(element);
      }
    }
    super.initState();
  }

  getFileExtension(String path) {
    return path.split("/").last.split(".").last;
  }

  showChooseCameraOrFilesModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  onTap: () async {
                    Navigator.pop(context);
                    await pushToCameraScreen(
                      context: context,
                      onFileAdded: (file) async {
                        File? picture = File(file);
                        files.add(picture);
                        compressedImageList.add(
                          await compressAndGetFile(
                              file: picture, minWidth: 175, minHeight: 175),
                        );
                        setState(() {});
                        widget.onAdd(picture);
                      },
                    );
                  },
                  backgroundColor: Colors.white,
                  text: "Tirar foto",
                  buttonTextStyle:
                      Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                  padding: const EdgeInsets.all(16),
                  sufix: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  buttonTextStyle:
                      Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                  padding: const EdgeInsets.all(16),
                  onTap: () async {
                    Navigator.pop(context);
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.any,
                    );

                    if (result != null) {
                      for (var element in result.paths) {
                        files.add(File(element!));
                        if (getFileExtension(element) == "png" ||
                            getFileExtension(element) == "jpg" ||
                            getFileExtension(element) == "jpeg") {
                          compressedImageList.add(
                            await compressAndGetFile(
                              file: File(element),
                              minWidth: 175,
                              minHeight: 175,
                            ),
                          );
                        } else {
                          compressedImageList.add(
                            File(element),
                          );
                        }
                        widget.onAdd(File(element));
                      }
                      setState(() {});
                    }
                  },
                  backgroundColor: Colors.white,
                  text: "Buscar arquivo",
                  sufix: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.upload_file_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (widget.showActions)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${files.length} de ${widget.limitOfFiles}",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey.withOpacity(.8),
                      value: (files.length * (100 / widget.limitOfFiles)) / 100,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 175,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              if (widget.showActions)
                Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: widget.componentsColor ??
                        Theme.of(context).primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (files.length < widget.limitOfFiles)
                            showChooseCameraOrFilesModal();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(.5),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GetIcon(
                            CustomIcons.plusSquareRegular,
                            color: widget.componentsColor ??
                                Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Incluir mídia",
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18,
                                ),
                      ),
                    ],
                  ),
                ),
              for (int i = 0; i < files.length; i++)
                GestureDetector(
                  onTap: () {
                    if (getFileExtension(files[i].path) == "png" ||
                        getFileExtension(files[i].path) == "jpg" ||
                        getFileExtension(files[i].path) == "jpeg") {
                      showImageDetails(files[i].path, context);
                    }
                    if (getFileExtension(files[i].path) == "mp4") {
                      showVideoDetails(files[i].path, context);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        Container(
                          width: 175,
                          decoration: BoxDecoration(
                            image: getFileExtension(files[i].path) == "png" ||
                                    getFileExtension(files[i].path) == "jpg" ||
                                    getFileExtension(files[i].path) == "jpeg"
                                ? DecorationImage(
                                    image: compressedImageList[i]
                                            .path
                                            .contains("http")
                                        ? NetworkImage(
                                            compressedImageList[i].path)
                                        : FileImage(
                                            compressedImageList[i],
                                          ) as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            color: widget.componentsColor ??
                                Theme.of(context).primaryColor.withOpacity(.1),
                          ),
                          child: getFileExtension(files[i].path) == "png" ||
                                  getFileExtension(files[i].path) == "jpg" ||
                                  getFileExtension(files[i].path) == "jpeg"
                              ? null
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GetIcon(
                                      getFileExtension(files[i].path) == "mp4"
                                          ? CustomIcons.videoRegular
                                          : CustomIcons.fileRegular,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        files[i].path.split('/').last,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        if (widget.showActions)
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  files.remove(files[i]);
                                  compressedImageList
                                      .remove(compressedImageList[i]);
                                  if (widget.onRemove != null) {
                                    widget.onRemove!(files[i]);
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: GetIcon(
                                    CustomIcons.trash,
                                    color: widget.componentsColor ??
                                        Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
