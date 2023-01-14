import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {},
        child: SvgPicture.asset(
          'assets/icons/ic_32_repeat_off.svg',
          width: size,
          height: size,
        )
    );
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
    return GestureDetector(
        onTap: () => {},
        child: SvgPicture.asset(
          'assets/icons/ic_32_prev_on.svg',
          width: size,
          height: size,
        )
    );
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
    return GestureDetector(
        onTap: () => {},
        child: SvgPicture.asset(
          'assets/icons/ic_32_play_900.svg',
          width: size,
          height: size,
        )
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
    return GestureDetector(
      onTap: () => {},
      child: SvgPicture.asset(
        'assets/icons/ic_80_play_shadow.svg',
        width: size,
        height: size,
      )
    );
  }
}


class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {},
        child: SvgPicture.asset(
          'assets/icons/ic_32_next_on.svg',
          width: size,
          height: size,
        )
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key, this.size = 32}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {},
        child: SvgPicture.asset(
          'assets/icons/ic_32_random_off.svg',
          width: size,
          height: size,
        )
    );
  }
}

class PlayerButton extends StatelessWidget {
  const PlayerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
