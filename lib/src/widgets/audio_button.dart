import 'package:flutter/material.dart';

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';

class AudioButton extends StatelessWidget {
  /// Creates audio button widget
  const AudioButton({
    Key? key,
    required this.onPressed,
    required this.recordingAudio,
  }) : super(key: key);

  /// Callback for audio button tap event
  final void Function()? onPressed;

  final bool recordingAudio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 16),
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.audioButtonIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.audioButtonIcon!,
                color: Color(0xFF0A81FF),
              )
            : recordingAudio
                ? (InheritedChatTheme.of(context).theme.sendButtonIcon != null
                    ? Image.asset(
                        InheritedChatTheme.of(context).theme.audioButtonIcon!,
                        color: Color(0xFF0A81FF),
                      )
                    : Image.asset(
                        'assets/icon-send.png',
                        color: Color(0xFF0A81FF),
                        package: 'flutter_chat_ui',
                      ))
                : (InheritedChatTheme.of(context).theme.audioButtonIcon != null
                    ? Image.asset(
                        InheritedChatTheme.of(context).theme.audioButtonIcon!,
                        color: Color(0xFF0A81FF),
                      )
                    : Icon(
                        Icons.mic_none,
                        color: Color(0xFF0A81FF),
                      )),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: recordingAudio
            ? InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel
            : InheritedL10n.of(context).l10n.audioButtonAccessibilityLabel,
      ),
    );
  }
}
