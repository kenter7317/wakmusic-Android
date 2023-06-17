import 'dart:developer';

import 'package:audio_service/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayBtns extends StatelessWidget {
  const PlayBtns({
    super.key,
    this.listCallback,
    this.isPlaylistView = false,
  });

  final bool isPlaylistView;

  final Future<List<Song?>> Function()? listCallback;

  @override
  Widget build(BuildContext context) {
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, isPlaylistView ? 8 : 16, 20, 12),
      color: isPlaylistView ? WakColor.grey100 : Colors.transparent,
      child: Row(
        children: [
          _buildBtn(
            context,
            iconName: 'ic_32_play_all',
            btnName: '전체재생',
            onTap: () async {
              final botNav = Provider.of<NavProvider>(context, listen: false);
              if (listCallback != null) {
                final list = await listCallback!();
                if (list.whereType<Song>().isEmpty) return;

                audioProvider.addQueueItems(
                  [...list.whereType<Song>()],
                  override: true,
                  autoplay: true,
                );
                botNav.subChange(1);
                botNav.subSwitchForce(true);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildBtn(
            context,
            iconName: 'ic_32_random_900',
            btnName: '랜덤재생',
            onTap: () async {
              final botNav = Provider.of<NavProvider>(context, listen: false);
              if (listCallback != null) {
                final list = await listCallback!();
                if (list.whereType<Song>().isEmpty) return;

                audioProvider.addQueueItems(
                  [...list.whereType<Song>()],
                  override: true,
                  randomize: true,
                  autoplay: true,
                );
                botNav.subChange(1);
                botNav.subSwitchForce(true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(
    BuildContext context, {
    required String iconName,
    required String btnName,
    required void Function()? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            border: Border.all(color: WakColor.grey200.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Spacer(flex: 4),
              SvgPicture.asset(
                'assets/icons/$iconName.svg',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 4),
              Text(
                btnName,
                style: WakText.txt14MH,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
