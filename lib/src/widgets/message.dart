import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/emoji_enlargement_behavior.dart';
import '../models/preview_tap_options.dart';
import '../util.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'text_message.dart';
import 'user_avatar.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.customMessageBuilder,
    this.customReplyMessageBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageMessageBuilder,
    required this.isTextMessageTextSelectable,
    required this.message,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    required this.onMessageReply,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.previewTapOptions,
    required this.replySwipeDirection,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    required this.showUserNameForRepliedMessage,
    this.textMessageBuilder,
    required this.usePreviewData,
    this.enableSwipe = true,
  }) : super(key: key);

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id
  final Widget Function(String userId)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author)
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Build a custom message inside predefined bubble
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Allows you to replace the default ReplyMessage widget inside Message widget
  final Widget Function(types.Message)? customReplyMessageBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// Build an image message inside predefined bubble
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [TextMessage.isTextMessageTextSelectable]
  final bool isTextMessageTextSelectable;

  /// Any message type
  final types.Message message;

  /// Maximum message width
  final int messageWidth;

  /// See [TextMessage.nameBuilder]
  final Widget Function(String userId)? nameBuilder;

  /// See [UserAvatar.onAvatarTap]
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on any message
  final void Function(BuildContext context, types.Message?) onMessageReply;

  /// Called when user makes a long press on status icon in any message
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [TextMessage.previewTapOptions]
  final PreviewTapOptions previewTapOptions;

  /// Swipe direction for reply message feature
  final SwipeDirection replySwipeDirection;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName]
  final bool showName;

  /// Show message's status
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  /// Show user name for replied message.
  final bool showUserNameForRepliedMessage;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.usePreviewData]
  final bool usePreviewData;

  final bool enableSwipe;

  Widget _avatarBuilder() => showAvatar
      ? avatarBuilder?.call(message.author.id) ??
          UserAvatar(author: message.author, onAvatarTap: onAvatarTap)
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) {
    return bubbleBuilder != null
        ? bubbleBuilder!(
            _messageBuilder(),
            message: message,
            nextMessageInGroup: roundBorder,
          )
        : enlargeEmojis && hideBackgroundOnEmojiMessages
            ? _messageBuilder()
            : Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: !currentUserIsAuthor ||
                          message.type == types.MessageType.image
                      ? InheritedChatTheme.of(context).theme.secondaryColor
                      : InheritedChatTheme.of(context).theme.primaryColor,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: _messageBuilder(),
                ),
              );
  }

  Widget _messageBuilder() {
    switch (message.type) {
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(
                message: fileMessage,
                showUserNameForRepliedMessage: showUserNameForRepliedMessage,
              );
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                message: imageMessage,
                messageWidth: messageWidth,
                showUserNameForRepliedMessage: showUserNameForRepliedMessage,
              );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                isTextMessageTextSelectable: isTextMessageTextSelectable,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                previewTapOptions: previewTapOptions,
                showName: showName,
                usePreviewData: usePreviewData,
                showUserNameForRepliedMessage: showUserNameForRepliedMessage,
              );
      default:
        return const SizedBox();
    }
  }

  Widget _statusBuilder(BuildContext context) {
    switch (message.status) {
      case types.Status.delivered:
      case types.Status.sent:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
                'assets/icon-error.png',
                color: InheritedChatTheme.of(context).theme.errorColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
                'assets/icon-seen.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InheritedChatTheme.of(context).theme.primaryColor,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);
    final _user = InheritedUser.of(context).user;
    final _currentUserIsAuthor = _user.id == message.author.id;
    final _enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
                emojiEnlargementBehavior, message as types.TextMessage);
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadiusDirectional.only(
      bottomEnd: Radius.circular(
        _currentUserIsAuthor
            ? roundBorder
                ? _messageBorderRadius
                : 0
            : _messageBorderRadius,
      ),
      bottomStart: Radius.circular(
        _currentUserIsAuthor || roundBorder ? _messageBorderRadius : 0,
      ),
      topEnd: Radius.circular(_messageBorderRadius),
      topStart: Radius.circular(_messageBorderRadius),
    );

    return SwipeableTile.swipeToTigger(
      behavior: HitTestBehavior.translucent,
      isEelevated: false,
      color: InheritedChatTheme.of(context).theme.backgroundColor,
      swipeThreshold: 0.3,
      direction: enableSwipe ? replySwipeDirection : SwipeDirection.none,
      onSwiped: (_) {
        onMessageReply(context, message);
      },
      backgroundBuilder: (
        _,
        SwipeDirection direction,
        AnimationController progress,
      ) {
        bool vibrated = false;
        return AnimatedBuilder(
          animation: progress,
          builder: (_, __) {
            if (progress.value > 0.9999 && !vibrated) {
              HapticFeedback.vibrate();
              vibrated = true;
            } else if (progress.value < 0.9999) {
              vibrated = false;
            }
            return Container(
              alignment: replySwipeDirection == SwipeDirection.endToStart
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Padding(
                padding: replySwipeDirection == SwipeDirection.endToStart
                    ? const EdgeInsets.only(right: 32.0)
                    : const EdgeInsets.only(left: 32.0),
                child: Transform.scale(
                  scale: Tween<double>(
                    begin: 0.0,
                    end: 1.2,
                  )
                      .animate(
                        CurvedAnimation(
                          parent: progress,
                          curve: const Interval(0.3, 1.0, curve: Curves.linear),
                        ),
                      )
                      .value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1FD189).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 24,
                    width: 24,
                    child:
                        InheritedChatTheme.of(context).theme.replyIcon != null
                            ? InheritedChatTheme.of(context).theme.replyIcon!
                            : Image.asset(
                                'assets/icon-reply.png',
                                color: Color(0xFF1FD189),
                                package: 'flutter_chat_ui',
                              ),
                  ),
                ),
              ),
            );
          },
        );
      },
      key: UniqueKey(),
      child: Container(
        alignment: _currentUserIsAuthor
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        margin: EdgeInsetsDirectional.only(
          bottom: 4,
          end: kIsWeb ? 0 : _query.padding.right,
          start: 20 + (kIsWeb ? 0 : _query.padding.left),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_currentUserIsAuthor && showUserAvatars) _avatarBuilder(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: messageWidth.toDouble(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onDoubleTap: () =>
                        onMessageDoubleTap?.call(context, message),
                    onLongPress: () =>
                        onMessageLongPress?.call(context, message),
                    onTap: () => onMessageTap?.call(context, message),
                    child: onMessageVisibilityChanged != null
                        ? VisibilityDetector(
                            key: Key(message.id),
                            onVisibilityChanged: (visibilityInfo) =>
                                onMessageVisibilityChanged!(message,
                                    visibilityInfo.visibleFraction > 0.1),
                            child: _bubbleBuilder(
                              context,
                              _borderRadius.resolve(Directionality.of(context)),
                              _currentUserIsAuthor,
                              _enlargeEmojis,
                            ),
                          )
                        : _bubbleBuilder(
                            context,
                            _borderRadius.resolve(Directionality.of(context)),
                            _currentUserIsAuthor,
                            _enlargeEmojis,
                          ),
                  ),
                ],
              ),
            ),
            if (_currentUserIsAuthor)
              Padding(
                padding: InheritedChatTheme.of(context).theme.statusIconPadding,
                child: showStatus
                    ? GestureDetector(
                        onLongPress: () =>
                            onMessageStatusLongPress?.call(context, message),
                        onTap: () => onMessageStatusTap?.call(context, message),
                        child: _statusBuilder(context),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
