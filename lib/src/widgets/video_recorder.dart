import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/widgets/preview_picture.dart';

import 'recording_indicator.dart';

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';

class VideoRecording {
  const VideoRecording({
    required this.filePath,
    required this.mimeType,
    required this.length,
  });

  final String filePath;
  final String mimeType;
  final Duration length;
}

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({Key? key}) : super(key: key);

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder>
    with WidgetsBindingObserver {
  CameraController? _controller;
  final List<CameraDescription> _cameras = [];
  late int? _currentCameraIndex;
  DateTime? _recordingStartTime;
  DateTime? _recordingStopTime;
  Timer? _recordingTimer;
  late File _picture;

  bool _isVideoCameraSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        _showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _controller;
    final size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Center(
                  child: cameraController == null
                      ? Text(
                          InheritedL10n.of(context)
                              .l10n
                              .noCameraAvailableMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: const Color(0xFF1FD189)),
                        )
                      : (!cameraController.value.isInitialized
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1FD189),
                              ),
                            )
                          : Container()),
                ),
                if (cameraController != null &&
                    cameraController.value.isInitialized)
                  Center(child: CameraPreview(cameraController)),
                if (cameraController != null &&
                    cameraController.value.isInitialized)
                  Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: _recordingStartTime != null
                                    ? null
                                    : () {
                                        if (_isVideoCameraSelected) {
                                          setState(() {
                                            _isVideoCameraSelected = false;
                                          });
                                        }
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: _isVideoCameraSelected
                                      ? Colors.black54
                                      : Colors.black,
                                  backgroundColor: _isVideoCameraSelected
                                      ? Colors.white30
                                      : Colors.white,
                                  disabledForegroundColor: Colors.black,
                                ),
                                child: const Text('Image'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!_isVideoCameraSelected) {
                                    setState(() {
                                      _isVideoCameraSelected = true;
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: _isVideoCameraSelected
                                      ? Colors.black
                                      : Colors.black54,
                                  backgroundColor: _isVideoCameraSelected
                                      ? Colors.white
                                      : Colors.white30,
                                ),
                                child: const Text('Video'),
                              ),
                            ),
                          ],
                        ),
                        if (!_isVideoCameraSelected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  InheritedL10n.of(context)
                                      .l10n
                                      .cancelVideoRecordingButton,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        if (_isVideoCameraSelected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  InheritedL10n.of(context)
                                      .l10n
                                      .cancelVideoRecordingButton,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              _recordingStartTime != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: RecordingIndicator(
                                        recording: _controller != null &&
                                            _controller!.value.isRecordingVideo,
                                        duration: _recordingStartTime == null
                                            ? null
                                            : Duration(
                                                milliseconds: (_recordingStopTime !=
                                                            null
                                                        ? _recordingStopTime!
                                                            .millisecondsSinceEpoch
                                                        : DateTime.now()
                                                            .millisecondsSinceEpoch) -
                                                    _recordingStartTime!
                                                        .millisecondsSinceEpoch,
                                              ),
                                      ),
                                    )
                                  :

                                  // Padding(
                                  //     padding: const EdgeInsets.only(left: 8.0),
                                  //     child: TextButton(
                                  //       onPressed: () {
                                  //         _startRecording();
                                  //       },
                                  //       child: const Text(
                                  //         'Start Record',
                                  //         style: TextStyle(color: Colors.white),
                                  //       ),
                                  //     ),
                                  //   ),
                                  SizedBox.shrink(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: IconButton(
                                  icon: InheritedChatTheme.of(context)
                                              .theme
                                              .sendButtonIcon !=
                                          null
                                      ? Image.asset(
                                          InheritedChatTheme.of(context)
                                              .theme
                                              .audioButtonIcon!,
                                          color: Colors.white,
                                        )
                                      : Image.asset(
                                          'assets/icon-send.png',
                                          color: Colors.white,
                                          package: 'flutter_chat_ui',
                                        ),
                                  onPressed: _controller != null &&
                                          _controller!.value.isInitialized &&
                                          _controller!.value.isRecordingVideo
                                      ? _sendVideoRecording
                                      : null,
                                  padding: EdgeInsets.zero,
                                  tooltip: InheritedL10n.of(context)
                                      .l10n
                                      .sendButtonAccessibilityLabel,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            if (cameraController != null &&
                cameraController.value.isInitialized &&
                _cameras.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  bottom: height * 0.18 / size.aspectRatio,
                  right: 10,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RawMaterialButton(
                    splashColor: Colors.grey,
                    highlightColor: Colors.grey,
                    shape: const CircleBorder(),
                    elevation: 1.0,
                    onPressed: () async {
                      if (_isVideoCameraSelected) {
                        await _startRecording();
                      } else {
                        final rawImage = await _takePicture();
                        _picture = File(rawImage!.path);
                      }
                    },
                    child: Visibility(
                      visible: _recordingStartTime == null,
                      child: const Icon(
                        shadows: <Shadow>[
                          Shadow(color: Colors.grey, blurRadius: 15.0),
                        ],
                        Icons.camera_sharp,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: height * 0.18 / size.aspectRatio,
                horizontal: 20,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.black38,
                      size: 60,
                    ),
                    if (cameraController != null &&
                        cameraController.value.isInitialized &&
                        _cameras.isNotEmpty)
                      IconButton(
                        tooltip: InheritedL10n.of(context)
                            .l10n
                            .videoRecordingSwitchCamera,
                        icon: const Icon(
                          CupertinoIcons.switch_camera,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _controller != null &&
                                _controller!.value.isInitialized &&
                                !_controller!.value.isRecordingVideo
                            ? () {
                                _currentCameraIndex =
                                    (_currentCameraIndex! + 1) %
                                        _cameras.length;
                                onNewCameraSelected(
                                  _cameras[_currentCameraIndex!],
                                );
                              }
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initCamera() async {
    final allCameras = await availableCameras();
    if (allCameras.isNotEmpty) {
      for (final camera in allCameras) {
        if (!_cameras
            .any((element) => element.lensDirection == camera.lensDirection)) {
          _cameras.add(camera);
        }
      }

      final frontCameraIndex = _cameras.indexWhere(
        (element) => element.lensDirection == CameraLensDirection.front,
      );
      if (frontCameraIndex > -1) {
        _currentCameraIndex = frontCameraIndex;
      } else {
        _currentCameraIndex = 0;
      }
      await onNewCameraSelected(_cameras[_currentCameraIndex!]);

      // await _startRecording();
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    _showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }

  void _showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _startRecording() async {
    final cameraController = _controller;
    if (cameraController == null) return;
    if (!cameraController.value.isInitialized) return;
    if (cameraController.value.isRecordingVideo) return;

    await cameraController.prepareForVideoRecording();
    _recordingStartTime = DateTime.now();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(
        const Duration(milliseconds: 10), (_) => setState(() {}));
    await cameraController.startVideoRecording();
    setState(() {});
  }

  Future<XFile?> _takePicture() async {
    final cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      final file = await cameraController.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPicture(
            picture: file,
            onPressed: _sendPicture,
          ),
        ),
      );
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _sendVideoRecording() async {
    final cameraController = _controller;
    if (cameraController == null) return;
    if (!cameraController.value.isInitialized) return;
    if (!cameraController.value.isRecordingVideo) return;
    _recordingStopTime = DateTime.now();
    _recordingTimer?.cancel();
    final videoFile = await cameraController.stopVideoRecording();
    setState(() {});
    Navigator.of(context).pop(
      VideoRecording(
        filePath: videoFile.path,
        mimeType: videoFile.mimeType ?? 'video/mp4',
        length: Duration(
          milliseconds: _recordingStopTime!.millisecondsSinceEpoch -
              _recordingStartTime!.millisecondsSinceEpoch,
        ),
      ),
    );
  }

  Future<void> _sendPicture() async {
    final cameraController = _controller;
    if (cameraController == null) return;
    if (!cameraController.value.isInitialized) return;
    Navigator.of(context).pop(
      VideoRecording(
        filePath: _picture.path,
        mimeType: 'image/jpg',
        length: Duration.zero,
      ),
    );
  }
}
