import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/widgets/common/sub_bot_nav.dart';

class MainBotNav extends StatefulWidget {
  const MainBotNav({super.key});

  @override
  State<MainBotNav> createState() => _MainBotNavState();
}

class _MainBotNavState extends State<MainBotNav> with TickerProviderStateMixin {
  late final List<AnimationController> animeList;

  @override
  void initState() {
    super.initState();
    animeList = [
      AnimationController(vsync: this),
      AnimationController(vsync: this),
      AnimationController(vsync: this),
      AnimationController(vsync: this),
      AnimationController(vsync: this)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final botNav = Provider.of<NavProvider>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
      child: Wrap(
        children: [
          if (botNav.subState) const SubBotNav(),
          if (botNav.mainState) mainBotNav(context),
        ],
      ),
    );
  }

  Widget mainBotNav(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: WakColor.grey100,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          botNavItem(context, 0, "home", "홈"),
          const SizedBox(width: 12),
          botNavItem(context, 1, "chart", "차트"),
          const SizedBox(width: 12),
          botNavItem(context, 2, "search", "검색"),
          const SizedBox(width: 12),
          botNavItem(context, 3, "artist", "아티스트"),
          const SizedBox(width: 12),
          botNavItem(context, 4, "keep", "보관함"),
        ],
      ),
    );
  }

  Widget botNavItem(BuildContext context, int idx, String icon, String label) {
    final botNav = Provider.of<NavProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final selProvider = Provider.of<SelectSongProvider>(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (botNav.curIdx != idx) {
            selProvider.clearList();
            if (audioProvider.isEmpty) {
              botNav.subSwitchForce(false);
            } else {
              botNav.subChange(1);
            }
            botNav.update(idx);
            for (var e in animeList) {
              if (e.status != AnimationStatus.forward) {
                e.reset();
              }
            }
          }
        },
        child: Container(
          height: 55,
          padding: const EdgeInsets.fromLTRB(0, 3, 0, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              botNav.curIdx == idx
                  ? Lottie.asset(
                      'assets/lottie/ic_$icon.json',
                      controller: animeList[idx],
                      width: 32,
                      height: 32,
                      fit: BoxFit.fill,
                      animate: true,
                      onLoaded: (composition) {
                        animeList[idx]
                          ..duration =
                              const Duration(seconds: 1, milliseconds: 1)
                          ..forward();
                      },
                    )
                  : Image.asset(
                      'assets/icons/ic_128_${icon}_disabled.png',
                      width: 32,
                      height: 32,
                    ),
              Text(
                label,
                style: WakText.txt12M.copyWith(
                    color: botNav.curIdx == idx
                        ? WakColor.grey900
                        : WakColor.grey400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
