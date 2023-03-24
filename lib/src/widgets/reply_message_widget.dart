import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ReplyMessageWidget extends StatelessWidget {
  final types.Message? message;
  final Function? onCancelReply;

  const ReplyMessageWidget({
    this.message,
    this.onCancelReply,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _text = '';
    String? _imageUri;
    String? _audioUri;
    String? _videoUri;
    if (message != null) {
      switch (message?.type) {
        case types.MessageType.file:
          final fileMessage = message as types.FileMessage;
          _text = fileMessage.name;
          break;
        case types.MessageType.image:
          final imageMessage = message as types.ImageMessage;
          _text = "Photo";
          _imageUri = imageMessage.uri;
          break;
        case types.MessageType.audio:
          final audioMessage = message as types.AudioMessage;
          _text = "Audio";
          _audioUri = audioMessage.uri;
          break;
        case types.MessageType.video:
          final videoMessage = message as types.VideoMessage;
          _text = "Video";
          _videoUri = videoMessage.uri;
          break;
        case types.MessageType.text:
          final textMessage = message as types.TextMessage;
          _text = textMessage.text;
          break;
        default:
          break;
      }
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            color: const Color(0xFF1BB9D5),
            width: 4,
          ),
          const SizedBox(width: 8),
          _imageUri != null
              ? Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUri,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(),
          _audioUri != null
              ? Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.audio_file,
                    ),
                  ),
                )
              : Container(),
          _videoUri != null
              ? Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const Icon(
                      Icons.video_file,
                    ),
                  ),
                )
              : Container(),
          Expanded(child: buildReplyMessage(_text)),
        ],
      ),
    );
  }

  Widget buildReplyMessage(String _text) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${message?.metadata?['userName']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1BB9D5)),
                ),
              ),
              if (onCancelReply != null)
                GestureDetector(
                  child: const Icon(Icons.close, size: 16),
                  onTap: () => onCancelReply?.call(),
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _text,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      );
}
