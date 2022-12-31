import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:flutter_chat_ui/src/widgets/recording_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initCamera();
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
          (element) => element.lensDirection == CameraLensDirection.front);
      if (frontCameraIndex > -1) {
        _currentCameraIndex = frontCameraIndex;
      } else {
        _currentCameraIndex = 0;
      }
      await onNewCameraSelected(_cameras[_currentCameraIndex!]);

      await _startRecording();
    }
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
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        _showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
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

  @override
  Widget build(BuildContext context) {
    final cameraController = _controller;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black26.withOpacity(0.8),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: cameraController == null
                  ? Text(
                      InheritedL10n.of(context).l10n.noCameraAvailableMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                    )
                  : (!cameraController.value.isInitialized
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Container()),
            ),
          ),
          if (cameraController != null && cameraController.value.isInitialized)
            SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: CameraPreview(cameraController),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                width: double.maxFinite,
                height: 80,
                child: Stack(
                  //mainAxisSize: MainAxisSize.max,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RecordingIndicator(
                          recording: _controller != null &&
                              _controller!.value.isRecordingVideo,
                          duration: _recordingStartTime == null
                              ? null
                              : Duration(
                                  milliseconds: (_recordingStopTime != null
                                          ? _recordingStopTime!
                                              .millisecondsSinceEpoch
                                          : DateTime.now()
                                              .millisecondsSinceEpoch) -
                                      _recordingStartTime!
                                          .millisecondsSinceEpoch),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
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
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: InheritedChatTheme.of(context)
                                      .theme
                                      .sendButtonIcon !=
                                  null
                              ? Image.asset(
                                  InheritedChatTheme.of(context)
                                      .theme
                                      .sendButtonIcon!,
                                  color: InheritedChatTheme.of(context)
                                      .theme
                                      .inputTextColor,
                                )
                              : Image.asset(
                                  'assets/icon-send.png',
                                  color: InheritedChatTheme.of(context)
                                      .theme
                                      .inputTextColor,
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
                    )
                  ],
                ),
              ),
            ),
          ),
          /*if (cameraController != null &&
              cameraController.value.isInitialized &&
              _cameras.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                  ),
                  child: IconButton(
                    tooltip: InheritedL10n.of(context)
                        .l10n
                        .videoRecordingSwitchCamera,
                    icon: const Icon(
                      Icons.switch_camera_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _controller != null &&
                            _controller!.value.isInitialized &&
                            !_controller!.value.isRecordingVideo
                        ? () async {
                            _currentCameraIndex =
                                (_currentCameraIndex! + 1) % _cameras.length;
                            await onNewCameraSelected(
                                _cameras[_currentCameraIndex!]);
                          }
                        : null,
                  ),
                ),
              ),
            ),*/
        ],
      ),
    );
  }
}
