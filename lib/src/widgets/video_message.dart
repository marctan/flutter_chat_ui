import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';
import 'state/inherited_user.dart';

/// A class that represents video message widget
class VideoMessage extends StatefulWidget {
  /// Creates an video message widget based on a [types.VideoMessage]
  const VideoMessage({
    Key? key,
    required this.message,
    required this.messageWidth,
    this.onStartPlayback,
  }) : super(key: key);

  static final durationFormat = DateFormat('m:ss', 'en_US');

  /// [types.VideoMessage]
  final types.VideoMessage message;

  /// Maximum message width
  final int messageWidth;

  /// Callback when video gets played
  final void Function(types.VideoMessage)? onStartPlayback;

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late VideoPlayerController _controller;

  bool _videoPlayerReady = false;
  bool _videoPaused = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.dispose();
  }

  Future<void> _initVideoPlayer() async {
    if (widget.message.uri.startsWith('http://') ||
        widget.message.uri.startsWith('https://')) {
      _controller = VideoPlayerController.network(widget.message.uri);
    } else if (!kIsWeb) {
      _controller = VideoPlayerController.file(File(widget.message.uri));
    }
    _controller.addListener(() async {
      setState(() {});
    });
    await _controller.initialize();
    setState(() {
      _videoPlayerReady = true;
    });
  }

  Future<void> _togglePlaying() async {
    if (!_videoPlayerReady) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
      setState(() {
        _videoPaused = true;
      });
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        await _controller.seekTo(const Duration());
      }

      await _controller.play();
      setState(() {
        _videoPaused = false;
      });

      if (widget.onStartPlayback != null) {
        widget.onStartPlayback!(widget.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _background = _user.id == widget.message.author.id
        ? InheritedChatTheme.of(context).theme.primaryColor
        : InheritedChatTheme.of(context).theme.secondaryColor;
    final _foreground = _user.id == widget.message.author.id
        ? Color(0xffffffff)
        : const Color(0xff1d1d21);

    if (_controller.value.isInitialized) {
      return Tooltip(
        message: InheritedL10n.of(context).l10n.videoPlayerAccessibilityLabel,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                reverseDuration: const Duration(milliseconds: 200),
                child: _controller.value.isPlaying
                    ? const SizedBox.shrink()
                    : Container(
                        color: Colors.black26,
                        child: Center(
                          child: InheritedChatTheme.of(context)
                                      .theme
                                      .playButtonIcon !=
                                  null
                              ? Image.asset(
                                  InheritedChatTheme.of(context)
                                      .theme
                                      .playButtonIcon!,
                                  color: _background,
                                )
                              : Icon(
                                  Icons.play_circle_fill,
                                  color: _background,
                                  size: 44,
                                ),
                        ),
                      ),
              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: InheritedChatTheme.of(context)
                      .theme
                      .videoTrackPlayedColor,
                  bufferedColor: InheritedChatTheme.of(context)
                      .theme
                      .videoTrackBufferedColor,
                  backgroundColor: InheritedChatTheme.of(context)
                      .theme
                      .videoTrackBackgroundColor,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      color: _background.withOpacity(0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3.0),
                      child: Text(
                        VideoMessage.durationFormat.format(
                          DateTime.fromMillisecondsSinceEpoch(
                            _controller.value.isPlaying || _videoPaused
                                ? (_controller.value.duration.inMilliseconds -
                                    _controller.value.position.inMilliseconds)
                                : _controller.value.duration.inMilliseconds,
                          ).toUtc(),
                        ),
                        style: InheritedChatTheme.of(context)
                            .theme
                            .receivedMessageCaptionTextStyle
                            .copyWith(color: _foreground),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _togglePlaying,
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
