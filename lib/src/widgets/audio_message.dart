import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/reply_message_widget.dart';
import 'package:flutter_chat_ui/src/widgets/wave_form.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart' show Level, Logger;

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';
import 'state/inherited_user.dart';

/// A class that represents audio message widget
class AudioMessage extends StatefulWidget {
  /// Creates an audio message widget based on a [types.AudioMessage]
  const AudioMessage({
    Key? key,
    required this.message,
    required this.messageWidth,
    this.onStartPlayback,
  }) : super(key: key);

  static final durationFormat = DateFormat('m:ss', 'en_US');

  /// [types.AudioMessage]
  final types.AudioMessage message;

  /// Maximum message width
  final int messageWidth;

  /// Audio playback callback
  final void Function(types.AudioMessage)? onStartPlayback;

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final _audioPlayer = FlutterSoundPlayer(logLevel: Level.nothing);

  bool _isLoading = false;
  bool _audioPlayerReady = false;
  bool _wasPlayingBeforeSeeking = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _color = Color(0xff1d1c21);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Column(
        children: [
          if (widget.message.repliedMessage != null)
            ReplyMessageWidget(
              message: widget.message.repliedMessage,
            ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _isLoading
                  ? const CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1FD189),
                      ),
                    )
                  : IconButton(
                      tooltip: _audioPlayer.isPlaying
                          ? InheritedL10n.of(context)
                              .l10n
                              .pauseButtonAccessibilityLabel
                          : InheritedL10n.of(context)
                              .l10n
                              .playButtonAccessibilityLabel,
                      padding: EdgeInsets.zero,
                      // ignore: prefer_expression_function_bodies
                      onPressed: _audioPlayerReady ? _togglePlaying : null,

                      icon: _audioPlayer.isPlaying
                          ? (InheritedChatTheme.of(context)
                                      .theme
                                      .pauseButtonIcon !=
                                  null
                              ? Image.asset(
                                  InheritedChatTheme.of(context)
                                      .theme
                                      .pauseButtonIcon!,
                                  color: _color,
                                )
                              : Icon(
                                  Icons.pause_circle_filled,
                                  color: _color,
                                  size: 44,
                                ))
                          : (InheritedChatTheme.of(context)
                                      .theme
                                      .playButtonIcon !=
                                  null
                              ? Image.asset(
                                  InheritedChatTheme.of(context)
                                      .theme
                                      .playButtonIcon!,
                                  color: _color,
                                )
                              : Icon(
                                  Icons.play_circle_fill,
                                  color: _color,
                                  size: 44,
                                )),
                    ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: widget.messageWidth.toDouble(),
                        height: 20,
                        child: _audioPlayer.isPlaying || _audioPlayer.isPaused
                            ? StreamBuilder<PlaybackDisposition>(
                                stream: _audioPlayer.onProgress,
                                builder: (context, snapshot) => WaveForm(
                                  accessibilityLabel: InheritedL10n.of(context)
                                      .l10n
                                      .audioTrackAccessibilityLabel,
                                  onTap: _togglePlaying,
                                  onStartSeeking: () async {
                                    _wasPlayingBeforeSeeking =
                                        _audioPlayer.isPlaying;
                                    if (_audioPlayer.isPlaying) {
                                      await _audioPlayer.pausePlayer();
                                    }
                                  },
                                  onSeek: snapshot.hasData
                                      ? (newPosition) async {
                                          await _audioPlayer
                                              .seekToPlayer(newPosition);
                                          if (_wasPlayingBeforeSeeking) {
                                            await _audioPlayer.resumePlayer();
                                            _wasPlayingBeforeSeeking = false;
                                          }
                                        }
                                      : null,
                                  waveForm: widget.message.waveForm,
                                  color: const Color(0xff1d1c21),
                                  duration: snapshot.hasData
                                      ? snapshot.data!.duration
                                      : widget.message.length,
                                  position: snapshot.hasData
                                      ? snapshot.data!.position
                                      : Duration.zero,
                                ),
                              )
                            : WaveForm(
                                accessibilityLabel: InheritedL10n.of(context)
                                    .l10n
                                    .audioTrackAccessibilityLabel,
                                onTap: _togglePlaying,
                                waveForm: widget.message.waveForm,
                                color: const Color(0xff1d1c21),
                                duration: widget.message.length,
                                position: Duration.zero,
                              ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (_audioPlayer.isPlaying || _audioPlayer.isPaused)
                        StreamBuilder<PlaybackDisposition>(
                          stream: _audioPlayer.onProgress,
                          builder: (context, snapshot) => Text(
                            AudioMessage.durationFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                snapshot.hasData
                                    ? snapshot.data!.duration.inMilliseconds -
                                        snapshot.data!.position.inMilliseconds
                                    : widget.message.length.inMilliseconds,
                              ).toUtc(),
                            ),
                            style: InheritedChatTheme.of(context)
                                .theme
                                .receivedMessageCaptionTextStyle
                                .copyWith(
                                  color: const Color(0xff1d1d21),
                                ),
                            textWidthBasis: TextWidthBasis.longestLine,
                          ),
                        )
                      else
                        Text(
                          AudioMessage.durationFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(
                              widget.message.length.inMilliseconds,
                            ).toUtc(),
                          ),
                          style: InheritedChatTheme.of(context)
                              .theme
                              .receivedMessageCaptionTextStyle
                              .copyWith(
                                color: const Color(0xff1d1d21),
                              ),
                          textWidthBasis: TextWidthBasis.longestLine,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopPlayer();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  void play(String uri) async {
    setState(() {
      _isLoading = true;
    });
    await _audioPlayer.startPlayer(
      fromURI: uri,
      whenFinished: () {
        setState(() {});
      },
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> stopPlayer() async {
    await _audioPlayer.stopPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.openPlayer();
    if (mounted) {
      setState(() {
        _audioPlayerReady = true;
      });
    }
  }

  Future<void> _togglePlaying() async {
    if (!_audioPlayerReady) return;
    if (_audioPlayer.isPlaying) {
      await _audioPlayer.pausePlayer();
    } else if (_audioPlayer.isPaused) {
      await _audioPlayer.resumePlayer();

      if (widget.onStartPlayback != null) {
        widget.onStartPlayback!(widget.message);
      }
    } else {
      await _audioPlayer.setSubscriptionDuration(
        const Duration(milliseconds: 10),
      );
      play(widget.message.uri);
      if (widget.onStartPlayback != null) {
        widget.onStartPlayback!(widget.message);
      }
    }
  }
}
