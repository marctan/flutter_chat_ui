import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/audio_button.dart';
import 'package:flutter_chat_ui/src/widgets/audio_recorder.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_replied_message.dart';
import 'package:flutter_chat_ui/src/widgets/replied_message.dart';
import 'package:flutter_chat_ui/src/widgets/video_button.dart';
import 'package:flutter_chat_ui/src/widgets/video_recorder.dart';

import '../../models/input_clear_mode.dart';
import '../../models/send_button_visibility_mode.dart';
import '../../util.dart';
import '../state/inherited_chat_theme.dart';
import '../state/inherited_l10n.dart';
import 'attachment_button.dart';
import 'input_text_field_controller.dart';
import 'send_button.dart';

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  const Input({
    super.key,
    this.customInputReplyMessageBuilder,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onCancelReplyPressed,
    required this.onSendPressed,
    this.options = const InputOptions(),
    required this.showUserNameForRepliedMessage,
    this.focusNode,
    this.onAudioRecorded,
    this.onStartAudioRecording,
    this.onVideoRecorded,
    this.onStartVideoRecording,
  });

  /// Allows you to replace the default ReplyMessage widget
  final Widget Function(types.Message)? customInputReplyMessageBuilder;

  /// See [RepliedMessage.onCancelReplyPressed]
  final void Function() onCancelReplyPressed;

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
  })? onVideoRecorded;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// See [AttachmentButton.onPressed].
  final VoidCallback? onAttachmentPressed;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText, {types.Message? repliedMessage})
      onSendPressed;

  /// Customisation options for the [Input].
  final InputOptions options;

  /// Show user names for replied messages.
  final bool showUserNameForRepliedMessage;

  final FocusNode? focusNode;

  @override
  State<Input> createState() => _InputState();
}

/// [Input] widget state.
class _InputState extends State<Input> {
  final _audioRecorderKey = GlobalKey<AudioRecorderState>();

  bool _recordingAudio = false;
  bool _audioUploading = false;
  bool _videoUploading = false;

  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
            (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        if (event is KeyDownEvent) {
          _handleSendPressed();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  bool _sendButtonVisible = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController =
        widget.options.textEditingController ?? InputTextFieldController();
    _handleSendButtonVisibilityModeChange();
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.sendButtonVisibilityMode !=
        oldWidget.options.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _inputFocusNode.requestFocus(),
        child: _inputBuilder(),
      );

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  Widget _leftWidget(final buttonPadding) {
    if (widget.isAttachmentUploading == true) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme.of(context).theme.inputTextColor,
          ),
        ),
      );
    } else {
      return AttachmentButton(
        onPressed: widget.onAttachmentPressed,
        isLoading: widget.isAttachmentUploading ?? false,
        padding: buttonPadding,
      );
    }
  }

  Widget _audioWidget() {
    if (_audioUploading == true) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme.of(context).theme.inputTextColor,
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
    if (_videoUploading == true) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme.of(context).theme.inputTextColor,
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
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 100),
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

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(
        _partialText,
        repliedMessage: InheritedRepliedMessage.of(context).repliedMessage,
      );
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  Widget _inputBuilder() {
    final query = MediaQuery.of(context);
    final buttonPadding = InheritedChatTheme.of(context)
        .theme
        .inputPadding
        .copyWith(left: 16, right: 16);
    final safeAreaInsets = isMobile
        ? EdgeInsets.fromLTRB(
            query.padding.left,
            0,
            query.padding.right,
            query.viewInsets.bottom + query.padding.bottom,
          )
        : EdgeInsets.zero;
    final textPadding = InheritedChatTheme.of(context)
        .theme
        .inputPadding
        .copyWith(left: 0, right: 0)
        .add(
          EdgeInsets.fromLTRB(
            widget.onAttachmentPressed != null ? 0 : 24,
            0,
            _sendButtonVisible ? 0 : 24,
            0,
          ),
        );

    return Focus(
      autofocus: true,
      child: Padding(
        padding: InheritedChatTheme.of(context).theme.inputMargin,
        child: Material(
          borderRadius: InheritedChatTheme.of(context).theme.inputBorderRadius,
          color: InheritedChatTheme.of(context).theme.inputBackgroundColor,
          child: Container(
            decoration:
                InheritedChatTheme.of(context).theme.inputContainerDecoration,
            padding: safeAreaInsets,
            child: Column(
              children: [
                if (InheritedRepliedMessage.of(context).repliedMessage != null)
                  widget.customInputReplyMessageBuilder != null
                      ? widget.customInputReplyMessageBuilder!(
                          InheritedRepliedMessage.of(context).repliedMessage!,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: RepliedMessage(
                            onCancelReplyPressed: widget.onCancelReplyPressed,
                            repliedMessage: InheritedRepliedMessage.of(context)
                                .repliedMessage,
                            showUserNames: widget.showUserNameForRepliedMessage,
                          ),
                        ),
                Row(
                  children: [
                    if (widget.onAttachmentPressed != null && !_recordingAudio)
                      _leftWidget(buttonPadding),
                    Expanded(
                      child: _recordingAudio
                          ? AudioRecorder(
                              key: _audioRecorderKey,
                              onCancelRecording: _cancelRecording,
                              disabled: _audioUploading,
                            )
                          : Padding(
                              padding: textPadding,
                              child: TextField(
                                controller: _textController,
                                cursorColor: InheritedChatTheme.of(context)
                                    .theme
                                    .inputTextCursorColor,
                                decoration: InheritedChatTheme.of(context)
                                    .theme
                                    .inputTextDecoration
                                    .copyWith(
                                      hintStyle: InheritedChatTheme.of(context)
                                          .theme
                                          .inputTextStyle
                                          .copyWith(
                                            color:
                                                InheritedChatTheme.of(context)
                                                    .theme
                                                    .inputTextColor
                                                    .withOpacity(0.5),
                                          ),
                                      hintText: InheritedL10n.of(context)
                                          .l10n
                                          .inputPlaceholder,
                                    ),
                                focusNode: widget.focusNode,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                minLines: 1,
                                onChanged: widget.options.onTextChanged,
                                onTap: widget.options.onTextFieldTap,
                                style: InheritedChatTheme.of(context)
                                    .theme
                                    .inputTextStyle
                                    .copyWith(
                                      color: InheritedChatTheme.of(context)
                                          .theme
                                          .inputTextColor,
                                    ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                    ),
                    Visibility(
                      visible: _sendButtonVisible,
                      child: SendButton(
                        onPressed: _handleSendPressed,
                        padding: buttonPadding,
                      ),
                    ),
                    Visibility(
                      visible:
                          widget.onAudioRecorded != null && !_sendButtonVisible,
                      child: _audioWidget(),
                    ),
                    Visibility(
                      visible: !kIsWeb &&
                          widget.onVideoRecorded != null &&
                          !_sendButtonVisible &&
                          !_recordingAudio,
                      child: _videoWidget(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class InputOptions {
  const InputOptions({
    this.inputClearMode = InputClearMode.always,
    this.onTextChanged,
    this.onTextFieldTap,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.textEditingController,
  });

  /// Controls the [Input] clear behavior. Defaults to [InputClearMode.always].
  final InputClearMode inputClearMode;

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;
}
