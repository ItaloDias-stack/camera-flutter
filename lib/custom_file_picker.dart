import 'dart:io';
import 'dart:typed_data';

import 'package:camera_test/camera_screen.dart';
import 'package:camera_test/image_details.dart';
import 'package:camera_test/misc.dart';
import 'package:camera_test/video_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:loomi_ui_flutter/utils/custom_icons.dart';
import 'package:loomi_ui_flutter/widgets/custom_button.dart';
import 'package:loomi_ui_flutter/widgets/get_icon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FilepickerScreen extends StatefulWidget {
  const FilepickerScreen({super.key});

  @override
  State<FilepickerScreen> createState() => _FilepickerScreenState();
}

class _FilepickerScreenState extends State<FilepickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomFilePicker(
          label: "Arquivos",
          onAdd: (file) {},
          limitOfFiles: 10,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            child: Row(
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
                      Container(
                        height: 15,
                        width: 15,
                        margin: const EdgeInsets.only(left: 15, right: 5),
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          backgroundColor: Colors.grey.withOpacity(.8),
                          value: (files.length * (100 / widget.limitOfFiles)) /
                              100,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: GridView.count(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                if (widget.showActions)
                  GestureDetector(
                    onTap: () {
                      if (files.length < widget.limitOfFiles) {
                        showFileSourceDialog();
                      }
                    },
                    child: Container(
                      width: 175,
                      decoration: BoxDecoration(
                        color: widget.componentsColor ??
                            Theme.of(context).primaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
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
                    child: Stack(
                      children: [
                        FileThumbnail(
                          file: files[i],
                          compressedFile: compressedImageList[i],
                        ),
                        if (widget.showActions)
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.all(10),
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
                                  padding: const EdgeInsets.all(8),
                                  child: GetIcon(
                                    CustomIcons.trash,
                                    color: widget.componentsColor ??
                                        Theme.of(context).primaryColor,
                                    heigth: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showFileSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ChooseFileSourceDialog(
          onCamera: () async {
            Navigator.pop(context);
            await pushToCameraScreen(
              context: context,
              onFileAdded: (file) async {
                File? picture = File(file);
                files.add(picture);
                compressedImageList.add(
                  await compressAndGetFile(
                    file: picture,
                    minWidth: 175,
                    minHeight: 175,
                  ),
                );
                setState(() {});
                widget.onAdd(picture);
              },
            );
          },
          onUpload: () async {
            Navigator.pop(context);
            FilePickerResult? result = await FilePicker.platform.pickFiles(
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
        );
      },
    );
  }
}

class FileThumbnail extends StatelessWidget {
  FileThumbnail({
    super.key,
    required this.file,
    required this.compressedFile,
  }) {
    _getVideoThumbnailBytes = getVideoThumbnailBytes();
  }

  final File file;
  final File compressedFile;
  Future<Uint8List>? _getVideoThumbnailBytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 175,
        height: 175,
        color: Theme.of(context).primaryColor.withOpacity(.1),
        child: getWidgetFromExtension(context),
      ),
    );
  }

  Widget getWidgetFromExtension(BuildContext context) {
    var extension = getFileExtension(file.path);

    switch (extension.toLowerCase()) {
      case "jpg":
      case "png":
      case "jpeg":
        return file.path.contains("http")
            ? Image.network(
                file.path,
                fit: BoxFit.cover,
              )
            : Image.file(
                file,
                fit: BoxFit.cover,
              );
      case "pdf":
        return PDFView(
          filePath: file.path,
        );
      case "mp4":
        return FutureBuilder<Uint8List>(
          future: _getVideoThumbnailBytes,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
          },
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetIcon(
              CustomIcons.fileRegular,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                file.path.split('/').last,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        );
    }
  }

  Future<Uint8List> getVideoThumbnailBytes() async {
    return (await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
        )) ??
        Uint8List(0);
  }
}

class ChooseFileSourceDialog extends StatelessWidget {
  const ChooseFileSourceDialog({
    super.key,
    required this.onCamera,
    required this.onUpload,
  });
  final Function() onCamera;
  final Function() onUpload;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onTap: onCamera,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.only(right: 10),
              text: "Câmera",
              buttonTextStyle:
                  Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
              prefix: Icon(
                Icons.camera_alt_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
            CustomButton(
              buttonTextStyle:
                  Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
              onTap: onUpload,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.only(right: 10),
              text: "Arquivos",
              prefix: Icon(
                Icons.folder_outlined,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getFileExtension(String path) {
  return path.split("/").last.split(".").last;
}
