import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/audio_button.dart';
import 'package:flutter_chat_ui/src/widgets/audio_recorder.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_replied_message.dart';
import 'package:flutter_chat_ui/src/widgets/reply_message_widget.dart';

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';
import 'video_button.dart';
import 'video_recorder.dart';

class InputMessage extends StatefulWidget {
  final FocusNode focusNode;
  final types.Message? replyMessage;
  final Function(types.PartialText message, {types.Message? repliedMessage})
      onSendMessage;
  final Function onCancelReply;
  final Function({types.Message? repliedMessage})? onAttachmentPressed;
  final bool? isAttachmentUploading;
  final bool enableAttachments;
  final bool enableAudio;
  final bool enableVideo;

  /// Called right when the user presses the audio recording button
  /// And returns true if and only if audio recording is possible
  /// Typically use to check audio recording permissions
  /// If this function returns false, the audio recording button will be disabled
  final Future<bool> Function()? onStartAudioRecording;

  /// See [AudioButton.onPressed]
  final Future<bool> Function({
    required Duration length,
    required String filePath,
    required List<double> waveForm,
    required String mimeType,
    types.Message? repliedMessage,
  })? onAudioRecorded;

  /// Called right when the user presses the video recording button
  /// And returns true if and only if video recording is possible
  /// Typically use to check video recording permissions
  /// If this function returns false, the video recording button will be disabled
  final Future<bool> Function()? onStartVideoRecording;

  /// See [VideoButton.onPressed]
  final Future<bool> Function({
    required Duration length,
    required String filePath,
    required String mimeType,
    types.Message? repliedMessage,
  })? onVideoRecorded;

  const InputMessage({
    required this.focusNode,
    this.replyMessage,
    required this.onCancelReply,
    required this.onSendMessage,
    this.onAttachmentPressed,
    this.isAttachmentUploading,
    this.enableAttachments = true,
    this.enableAudio = true,
    this.enableVideo = true,
    this.onAudioRecorded,
    this.onStartAudioRecording,
    this.onVideoRecorded,
    this.onStartVideoRecording,
    Key? key,
  }) : super(key: key);

  @override
  _InputMessageState createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  final _audioRecorderKey = GlobalKey<AudioRecorderState>();
  bool _sendButtonVisible = false;
  bool _recordingAudio = false;
  bool _audioUploading = false;
  bool _videoUploading = false;

  static const inputTopRadius = Radius.circular(12);
  static const inputBottomRadius = Radius.circular(24);
  final _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  Widget _audioWidget() {
    if (_audioUploading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF0A81FF),
          ),
        ),
      );
    } else {
      return AudioButton(
        onPressed: _toggleAudioRecording,
        recordingAudio: _recordingAudio,
      );
    }
  }

  Widget _videoWidget() {
    if (_videoUploading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF0A81FF),
          ),
        ),
      );
    } else {
      return VideoButton(
        onPressed: _toggleVideoRecording,
      );
    }
  }

  Future<void> _toggleAudioRecording() async {
    final inheritedReply = InheritedRepliedMessage.of(context);
    if (!_recordingAudio) {
      if (widget.onStartAudioRecording != null &&
          !(await widget.onStartAudioRecording!())) {
        return;
      }
      setState(() {
        _recordingAudio = true;
      });
    } else {
      final audioRecording =
          await _audioRecorderKey.currentState!.stopRecording();
      if (audioRecording != null) {
        setState(() {
          _audioUploading = true;
        });
        final success = await widget.onAudioRecorded!(
          length: audioRecording.duration,
          filePath: audioRecording.filePath,
          waveForm: audioRecording.decibelLevels,
          mimeType: audioRecording.mimeType,
          repliedMessage: inheritedReply.repliedMessage,
        );
        setState(() {
          _audioUploading = false;
        });
        if (success) {
          setState(() {
            _recordingAudio = false;
          });
        }
      }
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (widget.onStartVideoRecording != null &&
        !(await widget.onStartVideoRecording!())) {
      return;
    }
    final inheritedReply = InheritedRepliedMessage.of(context);

    final l10n = InheritedL10n.of(context).l10n;
    final theme = InheritedChatTheme.of(context).theme;
    final file = await Navigator.of(context).push<VideoRecording?>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            InheritedChatTheme(
          theme: theme,
          child: InheritedL10n(
            l10n: l10n,
            child: const VideoRecorder(),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ), // child is the value returned by pageBuilder
          );
        },
      ),
    );
    if (file != null) {
      setState(() {
        _videoUploading = true;
      });
      await widget.onVideoRecorded!(
        length: file.length,
        filePath: file.filePath,
        mimeType: file.mimeType,
        repliedMessage: inheritedReply.repliedMessage,
      );
      setState(() {
        _videoUploading = false;
      });
    }
  }

  void _cancelRecording() async {
    setState(() {
      _recordingAudio = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextControllerChange);
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);

    final isReplying = widget.replyMessage != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          if (widget.enableAttachments &&
              widget.onAttachmentPressed != null &&
              !_recordingAudio)
            ...attachmentButton(),
          const SizedBox(width: 15),
          Expanded(
            child: _recordingAudio
                ? AudioRecorder(
                    key: _audioRecorderKey,
                    onCancelRecording: _cancelRecording,
                    disabled: _audioUploading,
                  )
                : Column(
                    children: [
                      if (isReplying) buildReply(),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        controller: _textController,
                        focusNode: widget.focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 15),
                          filled: true,
                          fillColor: Colors.grey[100],
                          hintText: 'Type a message',
                          hintStyle: const TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  isReplying ? Radius.zero : inputBottomRadius,
                              topRight:
                                  isReplying ? Radius.zero : inputBottomRadius,
                              bottomLeft: inputBottomRadius,
                              bottomRight: inputBottomRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Visibility(
            visible: _sendButtonVisible,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: _handleSendPressed,
                child: const Icon(Icons.send, color: Color(0xFF007AFF)),
              ),
            ),
          ),
          Visibility(
            visible: !kIsWeb &&
                widget.enableVideo &&
                widget.onVideoRecorded != null &&
                !_sendButtonVisible &&
                !_recordingAudio,
            child: _videoWidget(),
          ),
          Visibility(
            visible: widget.enableAudio &&
                widget.onAudioRecorded != null &&
                !_sendButtonVisible,
            child: _audioWidget(),
          ),
        ],
      ),
    );
  }

  List<Widget> attachmentButton() {
    return [
      widget.isAttachmentUploading ?? false
          ? const SizedBox.shrink()
          : GestureDetector(
              onTap: () => widget.onAttachmentPressed!(
                      repliedMessage:
                          InheritedRepliedMessage.of(context).repliedMessage)
                  ?.call(),
              child: const Icon(
                Icons.add,
                color: Color(0xFF0A81FF),
                size: 25,
              ),
            )
    ];
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendMessage(_partialText,
          repliedMessage: InheritedRepliedMessage.of(context).repliedMessage);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text != '';
    });
  }

  Widget buildReply() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: inputTopRadius,
            topRight: inputTopRadius,
          ),
        ),
        child: ReplyMessageWidget(
          message: widget.replyMessage,
          onCancelReply: widget.onCancelReply,
        ),
      );
}
