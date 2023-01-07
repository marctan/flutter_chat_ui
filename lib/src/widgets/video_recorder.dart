import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
                  Expanded(
                    child: CameraPreview(cameraController),
                  ),
                Container(
                  color: Colors.black,
                  height: 100,
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
                      Row(
                        mainAxisAlignment: _isVideoCameraSelected
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (_isVideoCameraSelected)
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
                                : Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        _startRecording();
                                      },
                                      child: const Text(
                                        'Start Recording',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                          if (_isVideoCameraSelected)
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
                          Row(
                            children: [
                              if (cameraController != null &&
                                  cameraController.value.isInitialized &&
                                  _cameras.length > 1)
                                IconButton(
                                  tooltip: InheritedL10n.of(context)
                                      .l10n
                                      .videoRecordingSwitchCamera,
                                  icon: const Icon(
                                    Icons.switch_camera,
                                    color: Colors.white,
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
                              if (!_isVideoCameraSelected)
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
                              if (_isVideoCameraSelected)
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
                    ],
                  ),
                ),
              ],
            ),
            if (cameraController != null &&
                cameraController.value.isInitialized &&
                _cameras.length > 1 &&
                !_isVideoCameraSelected)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 130,
                  right: 10,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RawMaterialButton(
                    splashColor: Colors.black,
                    highlightColor: Colors.black,
                    shape: const CircleBorder(),
                    elevation: 1.0,
                    onPressed: () {},
                    child: const Icon(
                      shadows: <Shadow>[
                        Shadow(color: Colors.black, blurRadius: 15.0),
                      ],
                      Icons.camera_sharp,
                      color: Colors.white,
                      size: 80,
                    ),
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
}
