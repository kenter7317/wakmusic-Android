import 'dart:math';

import 'package:audio_service/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class AudioPlayerTester extends StatefulWidget {
  const AudioPlayerTester({
    super.key,
    this.enabled = false,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<AudioPlayerTester> createState() => _AudioPlayerTesterState();
}

class _AudioPlayerTesterState extends State<AudioPlayerTester> {
  bool popup = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          if (popup) _buildPopup(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: togglePopup,
        child: Icon(popup ? Icons.remove : Icons.add),
      ),
    );
  }

  void togglePopup() => setState(() => popup = !popup);

  Widget _buildRow(String title, String content) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: WakText.txt16B.copyWith(color: Colors.white),
          ),
          Text(
            content,
            style: WakText.txt14MH.copyWith(color: Colors.white),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(
        title,
        style: WakText.txt20B.copyWith(color: Colors.amber),
      ),
    );
  }

  Widget _buildIconButton(
    void Function() onPressed,
    IconData icon, {
    bool disabled = false,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: disabled ? WakColor.grey500 : Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(192),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'id: ${audioProvider.currentSong?.id ?? 'null'}',
            style: WakText.txt16B.copyWith(color: Colors.white),
          ),
          Text(
            '${audioProvider.currentSong?.title ?? 'title'} - ${audioProvider.currentSong?.artist ?? 'artist'}',
            style: WakText.txt20B.copyWith(color: Colors.white),
          ),
          _buildTitle('Current Playback'),
          _buildRow('Metadata', '${audioProvider.metadata.toMap()}'),
          const SizedBox(height: 5),
          _buildRow('State', '${audioProvider.playbackState}'),
          _buildRow('Duration', '${audioProvider.duration}'),
          StreamBuilder<Duration>(
            initialData: const Duration(),
            stream: audioProvider.position,
            builder: (_, snapshot) => _buildRow('Position', '${snapshot.data}'),
          ),
          _buildTitle('Queue'),
          _buildRow('length', '${audioProvider.queue.length}'),
          _buildRow('currIdx', '${audioProvider.currentIndex ?? -1 + 1}'),
          _buildRow('prevPlayable', '${audioProvider.prevPlayable}'),
          _buildRow('nextPlayable', '${audioProvider.nextPlayable}'),
          _buildRow('LoopMode', '${audioProvider.loopMode}'),
          _buildRow('Shuffle', '${audioProvider.shuffle}'),
          _buildRow(
            'ShuffledQueue',
            '[length: ${audioProvider.shuffledQueue.length}] ${audioProvider.shuffledQueue.map((e) => e.title)}',
          ),
          _buildTitle('Controls'),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.83,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildIconButton(
                  audioProvider.nextLoopMode,
                  () {
                    switch (audioProvider.loopMode) {
                      case LoopMode.none:
                      case LoopMode.all:
                        return Icons.repeat;
                      case LoopMode.single:
                        return Icons.repeat_one;
                    }
                  }(),
                  disabled: audioProvider.loopMode == LoopMode.none,
                ),
                _buildIconButton(audioProvider.toPrevious, Icons.skip_previous),
                StreamBuilder<PlaybackState>(
                  initialData: audioProvider.playbackState,
                  stream: audioProvider.playbackStream,
                  builder: (context, snapshot) => _buildIconButton(
                    audioProvider.playPause,
                    () {
                      switch (snapshot.data) {
                        case PlaybackState.playing:
                          return Icons.pause;
                        case PlaybackState.ended:
                          return Icons.replay;
                        default:
                          return Icons.play_arrow;
                      }
                    }(),
                  ),
                ),
                _buildIconButton(audioProvider.toNext, Icons.skip_next),
                _buildIconButton(audioProvider.stop, Icons.stop),
                _buildIconButton(
                  audioProvider.toggleShuffle,
                  Icons.shuffle,
                  disabled: !audioProvider.shuffle,
                ),
              ],
            ),
          ),
          StreamBuilder(
            initialData: const Duration(),
            stream: audioProvider.position,
            builder: (context, snapshot) {
              return _SeekBar(
                duration: audioProvider.duration,
                position: snapshot.data ?? const Duration(),
                onChangeEnd: (v) {
                  audioProvider.seek(v.inSeconds.toDouble());
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const _SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  })  : bufferedPosition = Duration.zero,
        super(key: key);

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {},
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: value,
            onChanged: (value) {
              if (!_dragging) {
                _dragging = true;
              }
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragging = false;
            },
          ),
        ),
        Positioned(
          left: 16.0,
          bottom: -4,
          child: Text(
            _format(widget.position),
            style: WakText.txt12L.copyWith(color: Colors.white),
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: -4,
          child: Text(
            _format(widget.duration),
            style: WakText.txt12L.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _format(Duration duration) {
    String h = duration.inHours > 0 ? '${duration.inHours}:' : '';
    String m = intl.NumberFormat(h.isEmpty ? '#0:' : '00:')
        .format(duration.inMinutes % 60);
    String s = intl.NumberFormat('00').format(duration.inSeconds % 60);
    return '$h$m$s';
  }
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
