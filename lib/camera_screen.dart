import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:camera_test/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

Future pushToCameraScreen({
  required BuildContext context,
  String? popUntil,
  required Function(String) onFileAdded,
}) async {
  List<CameraDescription> cameras = await availableCameras();
  // ignore: use_build_context_synchronously
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CameraScreen(
        cameras: cameras,
        onSave: (picture) {
          if (popUntil != null) {
            Navigator.popUntil(
              context,
              ModalRoute.withName(popUntil),
            );
          }
          onFileAdded(picture.path);
        },
      ),
    ),
  );
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(File picture) onSave;
  const CameraScreen({super.key, required this.cameras, required this.onSave});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;
  double _currentZoom = 1.0;
  final double _minAvailableZoom = 1.0;
  final double _maxAvailableZoom = 3.0;
  bool _isFlashOn = false;
  int pointerCount = 0;

  @override
  void initState() {
    initCamera(widget.cameras[0]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.dispose();
    } else {
      initCamera(widget.cameras[0]);
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _cameraController.setFlashMode(FlashMode.off);
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      if (_isFlashOn) {
        await _cameraController.setFlashMode(FlashMode.torch);
      } else {
        await _cameraController.setFlashMode(FlashMode.off);
      }
      var picture = File((await _cameraController.takePicture()).path);
      await _cameraController.setFlashMode(FlashMode.off);
      if (_cameraController.description.lensDirection ==
          CameraLensDirection.front) {
        final originalImage = img.decodeImage(picture.readAsBytesSync())!;
        final flippedImage = img.flipHorizontal(originalImage);
        final directory = await getApplicationDocumentsDirectory();
        final newPath = '${directory.path}/${DateTime.now()}.jpg';
        final newFile = File(newPath);
        await newFile.writeAsBytes(img.encodeJpg(flippedImage));
        picture = newFile;
      }
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
            onSave: widget.onSave,
            controller: _cameraController,
            picture: picture,
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future _handleTapUp(PointerUpEvent event) async {
    try {
      if (!_cameraController.value.isInitialized) {
        return;
      }
      showFocusCircle = true;
      x = event.position.dx;
      y = event.position.dy;
      final size = MediaQuery.of(context).size;
      final focusPoint = Offset(x / size.width, y / size.height);

      await _cameraController.setFocusPoint(focusPoint);
      setState(() {
        Future.delayed(const Duration(seconds: 1)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    } catch (e) {
      print('Error focusing camera: $e');
    }
  }

  void _handleZoomUpdate(PointerMoveEvent event) {
    double zoomDelta = event.delta.dy / 100.0;
    double newZoom = _currentZoom + zoomDelta;
    newZoom = newZoom.clamp(_minAvailableZoom, _maxAvailableZoom);

    setState(() {
      _currentZoom = newZoom;
    });
    _cameraController.setZoomLevel(newZoom);
  }

  Future _switchCamera() async {
    final cameras = await availableCameras();
    final isFrontCamera = _cameraController.description.lensDirection ==
        CameraLensDirection.front;

    CameraDescription newCamera;
    if (isFrontCamera) {
      newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back);
    } else {
      newCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
    }

    if (_cameraController.value.isRecordingVideo) {
      await _cameraController.stopVideoRecording();
    }

    await _cameraController.dispose();

    setState(() {
      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.max,
      );
    });
    initCamera(newCamera);
    setState(() {});
  }

  void _toggleFlash() async {
    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController.value.isInitialized
          ? Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(
                    _cameraController,
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(.4),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          height: 30,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Câmera",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Listener(
                            onPointerDown: (event) {
                              pointerCount++;
                            },
                            onPointerMove: (event) {
                              if (pointerCount > 1) {
                                _handleZoomUpdate(event);
                              }
                            },
                            onPointerUp: (event) async {
                              pointerCount--;
                              if (pointerCount == 0) {
                                await _handleTapUp(event);
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              height: MediaQuery.of(context).size.height - 100,
                              color: Colors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio:
                                      _cameraController.value.aspectRatio * 2,
                                  child: CameraPreview(
                                    _cameraController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 45,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _toggleFlash();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white.withOpacity(.2),
                                  ),
                                  child: Icon(
                                    _isFlashOn
                                        ? Icons.flash_on_outlined
                                        : Icons.flash_off_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await takePicture();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  _switchCamera();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white.withOpacity(.2),
                                  ),
                                  child: const Icon(
                                    Icons.cached,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showFocusCircle)
                  Positioned(
                    top: y - 20,
                    left: x - 20,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            ),
    );
  }
}
