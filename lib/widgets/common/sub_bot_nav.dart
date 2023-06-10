import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/player/player_playlist_view.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/utils/number_format.dart';

import '../../screens/player/player_view.dart';

class SubBotNav extends StatefulWidget {
  const SubBotNav({super.key});

  @override
  State<SubBotNav> createState() => _SubBotNavState();
}

class _SubBotNavState extends State<SubBotNav> {
  // 수정 (수정 후 삭제)
  bool tempLike = true;
  bool tempIsPlaying = true;
  RepeatType tempRepeat = RepeatType.none;
  bool tempRandom = false;

  @override
  Widget build(BuildContext context) {
    final botNav = Provider.of<NavProvider>(context);
    final List<Widget> barList = [
      playDetailBar(),
      playerBar(PlayerBarType.main),
      playerBar(PlayerBarType.sub),
      editBar(context, EditBarType.playListBar),
      editBar(context, EditBarType.chartBar),
      editBar(context, EditBarType.keepBar),
      editBar(context, EditBarType.keepDetailBar),
      editBar(context, EditBarType.keepListBar),
      editBar(context, EditBarType.keepProfileBar)
    ];
    return barList[botNav.subIdx];
  }

  /* 임시 노래재생상세 바 */
  Widget playDetailBar() {
    final botNav = Provider.of<NavProvider>(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: WakColor.grey100,
            width: 1.0,
          ),
        ),
      ),
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          tempLike == true
              ? playDetailBarBtn("ic_32_heart_on", koreanNumberFormater(1217),
                  txtColor: WakColor.pink, onTap: () {
                  setState(() {
                    tempLike = !tempLike;
                  });
                })
              : playDetailBarBtn("ic_32_heart_off", koreanNumberFormater(1217),
                  onTap: () {
                  setState(() {
                    tempLike = !tempLike;
                  });
                }), // 수정 (좋아요 상태 연결)
          playDetailBarBtn(
            "ic_32_views",
            koreanNumberFormater(10000),
          ), // 수정 (조회수 연결)
          playDetailBarBtn(
            "ic_32_playadd_900",
            "노래담기",
          ), // 수정 (onTap 액션 필요)
          playDetailBarBtn("ic_32_play_list", "재생목록", edgePadding: false,
              onTap: () {
            botNav.subChange(2);
            Navigator.push(
                botNav.pageContext,
                MaterialPageRoute(
                    builder: (context) => const PlayerPlayList()));
          }),
        ],
      ),
    );
  }

  Widget playDetailBarBtn(String icon, String txt,
      {Color txtColor = WakColor.grey400, bool edgePadding = true, onTap}) {
    return Padding(
      padding: edgePadding ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 3, 0, 6),
          width: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/$icon.svg',
                width: 32,
                height: 32,
              ),
              Text(
                txt,
                style: WakText.txt12M.copyWith(color: txtColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* 임시 노래 재생 바 */
  Widget playerBar(PlayerBarType type) {
    final botNav = Provider.of<NavProvider>(context);
    return GestureDetector(
      onTap: () {
        if (type == PlayerBarType.main) {
          botNav.mainSwitchForce(false);
          botNav.subSwitchForce(true);
          botNav.subChange(0);
          Navigator.push(
            botNav.pageContext,
            MaterialPageRoute(builder: (context) => const Player()),
          );
        }
      },
      child: Stack(
        children: [
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 7, 0, 8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ExtendedImage.network(
                      'https://i.ytimg.com/vi/A5Zge2ggBSA/hqdefault.jpg',
                      fit: BoxFit.cover,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                type == PlayerBarType.main
                    ? Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "리와인드 (RE:WIND)",
                                    style: WakText.txt14MH,
                                  ), // 수정
                                  Text(
                                    "이세계아이돌",
                                    style: WakText.txt12L,
                                  ), // 수정
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            tempIsPlaying
                                ? iconBtn("ic_32_stop", edgePadding: true,
                                    onTap: () {
                                    setState(() {
                                      tempIsPlaying = !tempIsPlaying;
                                    });
                                  })
                                : iconBtn("ic_32_play_900", edgePadding: true,
                                    onTap: () {
                                    setState(() {
                                      tempIsPlaying = !tempIsPlaying;
                                    });
                                  }), // 수정
                            iconBtn(
                              "ic_32_close",
                              edgePadding: false,
                            ), // 수정
                          ],
                        ),
                      )
                    : Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              () {
                                switch (tempRepeat) {
                                  case RepeatType.all:
                                    return iconBtn("ic_32_repeat_on_all",
                                        onTap: () {
                                      setState(() {
                                        tempRepeat = RepeatType.one;
                                      });
                                    });
                                  case RepeatType.one:
                                    return iconBtn("ic_32_repeat_on_1",
                                        onTap: () {
                                      setState(() {
                                        tempRepeat = RepeatType.none;
                                      });
                                    });
                                  default:
                                    return iconBtn("ic_32_repeat_off",
                                        onTap: () {
                                      setState(() {
                                        tempRepeat = RepeatType.all;
                                      });
                                    }); // 수정 (실제 플레이어와 연결)
                                }
                              }(),
                              iconBtn("ic_32_prev_on"), // 수정 (실제 플레이어와 연결)
                              tempIsPlaying
                                  ? iconBtn("ic_32_stop", onTap: () {
                                      setState(() {
                                        tempIsPlaying = !tempIsPlaying;
                                      });
                                    })
                                  : iconBtn("ic_32_play_900", onTap: () {
                                      setState(() {
                                        tempIsPlaying = !tempIsPlaying;
                                      });
                                    }), // 수정 (실제 플레이어와 연결)
                              iconBtn("ic_32_next_on"), // 수정 (실제 플레이어와 연결)
                              tempRandom
                                  ? iconBtn("ic_32_random_on",
                                      edgePadding: true, onTap: () {
                                      setState(() {
                                        tempRandom = !tempRandom;
                                      });
                                    })
                                  : iconBtn("ic_32_random_off",
                                      edgePadding: true, onTap: () {
                                      setState(() {
                                        tempRandom = !tempRandom;
                                      });
                                    }), // 수정 (실제 플레이어와 연결)
                            ]),
                      ),
              ],
            ),
          ),
          Container(height: 1, color: WakColor.lightBlue), // 수정 (프로그레스 바)
        ],
      ),
    );
  }

  Widget iconBtn(String icon, {edgePadding = true, onTap}) {
    return Padding(
      padding: edgePadding ? const EdgeInsets.only(right: 20) : EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: SvgPicture.asset(
          "assets/icons/$icon.svg",
          width: 32,
          height: 32,
        ),
      ),
    );
  }

  /* 곡 선택 */
  Widget editBar(BuildContext context, EditBarType type) {
    final selNav = Provider.of<SelectSongProvider>(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          color: WakColor.lightBlue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (type.showSelect)
                selNav.selNum != selNav.maxSel
                    ? editBarBtn("ic_32_check_off", "전체선택",
                        onTap: selNav.addAllSong)
                    : editBarBtn("ic_32_check_on", "전체선택해제",
                        onTap: selNav.clearList),
              if (type.showSongAdd) editBarBtn("ic_32_playadd_25", "노래담기"),
              if (type.showPlayListAdd) editBarBtn("ic_32_play_add", "재생목록추가"),
              if (type.showPlay) editBarBtn("ic_32_play_25", "재생"),
              if (type.showDelete) editBarBtn("ic_32_delete", "삭제"),
              if (type.showEdit) editBarBtn("ic_32_edit", "편집"),
              if (type.showShare) editBarBtn("ic_32_share-1", "공유하기"),
              if (type.showProfileChange) editBarBtn("ic_32_profile", "프로필 변경"),
              if (type.showNicknameChange) editBarBtn("ic_32_edit", "닉네임 수정")
            ],
          ),
        ),
        if (selNav.selNum > 0)
          Positioned(
            top: -16,
            left: 20 - (selNav.selNum.toString().length - 1) * 4,
            child: Container(
              height: 32,
              width: 32 + (selNav.selNum.toString().length - 1) * 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: WakColor.dark.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                selNav.selNum.toString(),
                style: WakText.txt18B.copyWith(color: WakColor.lightBlue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

Widget editBarBtn(String icon, String txt, {onTap}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/$icon.svg', width: 32, height: 32),
            Text(
              txt,
              style: WakText.txt12M.copyWith(color: WakColor.grey25),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

enum EditBarType {
  playListBar(true, true, false, true, false, false, false, false, false),
  chartBar(true, true, true, false, true, false, false, false, false),
  keepBar(true, true, true, true, false, false, false, false, false),
  keepDetailBar(false, false, false, false, false, true, true, false, false),
  keepListBar(true, true, false, false, false, false, false, false, false),
  keepProfileBar(false, false, false, false, false, false, false, true, true);

  const EditBarType(
      this.showSelect,
      this.showSongAdd,
      this.showPlayListAdd,
      this.showDelete,
      this.showPlay,
      this.showEdit,
      this.showShare,
      this.showProfileChange,
      this.showNicknameChange);
  final bool showSelect;
  final bool showSongAdd;
  final bool showPlayListAdd;
  final bool showDelete;
  final bool showPlay;
  final bool showEdit;
  final bool showShare;
  final bool showProfileChange;
  final bool showNicknameChange;
}

enum PlayerBarType {
  main,
  sub;
}

enum RepeatType { none, one, all }
