import 'package:flutter/material.dart';

import 'state/inherited_chat_theme.dart';
import 'state/inherited_l10n.dart';

class VideoButton extends StatelessWidget {
  /// Creates audio button widget
  const VideoButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  /// Callback for video button tap event
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 16),
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.videoButtonIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.videoButtonIcon!,
                color: InheritedChatTheme.of(context).theme.inputTextColor,
              )
            : Icon(
                Icons.videocam_outlined,
                color: InheritedChatTheme.of(context).theme.inputTextColor,
              ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: InheritedL10n.of(context).l10n.videoButtonAccessibilityLabel,
      ),
    );
  }
}
