import 'package:audio_service/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/style/colors.dart';

import '../../models/providers/audio_provider.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
        onTap: () {
          audioProvider.nextLoopMode();
        },
        child: SvgPicture.asset(
          () {
            switch (audioProvider.loopMode) {
              case LoopMode.none:
                return 'assets/icons/ic_32_repeat_off.svg';
              case LoopMode.all:
                return 'assets/icons/ic_32_repeat_on_all.svg';
              case LoopMode.single:
                return 'assets/icons/ic_32_repeat_on_1.svg';
            }
          }(),
          width: size,
          height: size,
        ));
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({
    Key? key,
    this.size = 32,
  }) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
        onTap: () {
          audioProvider.toPrevious();
        },
        child: SvgPicture.asset(
          'assets/icons/ic_32_prev_on.svg',
          width: size,
          height: size,
        ));
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key? key,
    this.size = 32,
  }) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return StreamBuilder<PlaybackState>(
      initialData: audioProvider.playbackState,
      stream: audioProvider.playbackStream,
      builder: (context, snapshot) => GestureDetector(
        onTap: () {
          audioProvider.playPause();
        },
        child: SvgPicture.asset(
          () {
            switch (snapshot.data) {
              case PlaybackState.playing:
                return 'assets/icons/ic_32_stop.svg';
              default:
                return 'assets/icons/ic_32_play_900.svg';
            }
          }(),
          width: size,
          height: size,
        ),
      ),
    );
  }
}

class PlayCircleButton extends StatelessWidget {
  const PlayCircleButton({
    Key? key,
    this.size = 80,
  }) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return StreamBuilder<PlaybackState>(
        initialData: audioProvider.playbackState,
        stream: audioProvider.playbackStream,
        builder: (context, snapshot) => GestureDetector(
              onTap: () {
                audioProvider.playPause();
              },
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: WakColor.dark.withOpacity(0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  () {
                    switch (snapshot.data) {
                      case PlaybackState.playing:
                        return 'assets/icons/ic_80_stop_shadow.svg';
                      case PlaybackState.ended:
                        return 'assets/icons/ic_80_replay_shadow.svg';
                      default:
                        return 'assets/icons/ic_80_play_shadow.svg';
                    }
                  }(),
                  width: size,
                  height: size,
                ),
              ),
            ));
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
        onTap: () {
          audioProvider.toNext();
        },
        child: SvgPicture.asset(
          'assets/icons/ic_32_next_on.svg',
          width: size,
          height: size,
        ));
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
        onTap: () {
          audioProvider.toggleShuffle();
        },
        child: SvgPicture.asset(
          audioProvider.shuffle
              ? 'assets/icons/ic_32_random_on.svg'
              : 'assets/icons/ic_32_random_off.svg',
          width: size,
          height: size,
        ));
  }
}

class PlayerButton extends StatelessWidget {
  const PlayerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          RepeatButton(),
          PreviousSongButton(),
          PlayCircleButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class PlayerBottomButton extends StatelessWidget {
  const PlayerBottomButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
