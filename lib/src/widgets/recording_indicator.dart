import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordingIndicator extends StatefulWidget {
  const RecordingIndicator({
    Key? key,
    this.recording = false,
    this.duration,
  }) : super(key: key);

  final bool recording;
  final Duration? duration;

  @override
  _RecordingIndicatorState createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  final _recorderDurationFormat = DateFormat('m:ss,SS', 'en_US');
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String time;
    if (widget.duration != null) {
      time = _recorderDurationFormat.format(
          DateTime.fromMillisecondsSinceEpoch(widget.duration!.inMilliseconds));
      time = time.substring(0, time.length - 1);
    } else {
      time = '';
    }

    return Row(
      children: [
        if (widget.recording)
          FadeTransition(
            opacity: _animationController,
            child: const Icon(
              Icons.fiber_manual_record,
              color: Colors.red,
              size: 16.0,
            ),
          )
        else
          const SizedBox(
            width: 16.0,
          ),
        const SizedBox(width: 8.0),
        if (widget.duration != null)
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
