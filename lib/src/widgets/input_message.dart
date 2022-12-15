import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/inherited_replied_message.dart';
import 'package:flutter_chat_ui/src/widgets/reply_message_widget.dart';

class InputMessage extends StatefulWidget {
  final FocusNode focusNode;
  final types.Message? replyMessage;
  final Function(types.PartialText message, {types.Message? repliedMessage})
      onSendMessage;
  final Function onCancelReply;
  final Function? onAttachmentPressed;
  final bool? isAttachmentUploading;
  final bool enableAttachments;

  const InputMessage({
    required this.focusNode,
    this.replyMessage,
    required this.onCancelReply,
    required this.onSendMessage,
    this.onAttachmentPressed,
    this.isAttachmentUploading,
    this.enableAttachments = true,
    Key? key,
  }) : super(key: key);

  @override
  _InputMessageState createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  static const inputTopRadius = Radius.circular(12);
  static const inputBottomRadius = Radius.circular(24);
  final _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          if(widget.enableAttachments) ...attachmentButton(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              children: [
                if (isReplying) buildReply(),
                TextField(
                  controller: _textController,
                  focusNode: widget.focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 15),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Type a message',
                    hintStyle: const TextStyle(fontSize: 16),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.only(
                        topLeft: isReplying ? Radius.zero : inputBottomRadius,
                        topRight: isReplying ? Radius.zero : inputBottomRadius,
                        bottomLeft: inputBottomRadius,
                        bottomRight: inputBottomRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: _handleSendPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1FD189),
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> attachmentButton() {
    return [
      widget.isAttachmentUploading ?? false
          ? const CircularProgressIndicator()
          : GestureDetector(
              onTap: () => widget.onAttachmentPressed?.call(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1FD189),
                ),
                child: const Icon(Icons.add, color: Colors.white),
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
