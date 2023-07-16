import 'package:audio_service/models/enums.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/player/player_playlist_view.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/services/throttle.dart';
import 'package:wakmusic/utils/load_image.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

import '../../models/providers/audio_provider.dart';
import '../../models/providers/nav_provider.dart';
import '../../models/providers/select_song_provider.dart';
import '../../services/debounce.dart';
import '../../style/colors.dart';
import '../../style/text_styles.dart';
import '../../utils/number_format.dart';
import '../common/keep_song_pop_up.dart';
import '../common/pop_up.dart';
import '../show_modal.dart';

class PlayerViewBottom extends StatelessWidget {
  const PlayerViewBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final debounce = Debounce(milliseconds: 500);
    final keepModel = Provider.of<KeepViewModel>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final selProvider = Provider.of<SelectSongProvider>(context);
    final navProvider = Provider.of<NavProvider>(context);
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
          keepModel.loginStatus == LoginStatus.before
              ? FutureBuilder(
                  future:
                      API.like.get(songId: audioProvider.currentSong?.id ?? ''),
                  builder: (context, snapshot) {
                    return playDetailBarBtn("ic_32_heart_off",
                        koreanNumberFormater(snapshot.data ?? 0), onTap: () {
                      showModal(
                        context: context,
                        builder: (context) => const PopUp(
                          type: PopUpType.txtTwoBtn,
                          msg: '로그인이 필요한 서비스입니다.\n로그인 하시겠습니까?',
                        ),
                      ).then((value) {
                        navProvider.update(4);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    });
                  },
                )
              : FutureBuilder(
                  future:
                      API.like.get(songId: audioProvider.currentSong?.id ?? ''),
                  builder: (context, snapshot) {
                    return playDetailBarBtn(
                      keepModel.likes.contains(audioProvider.currentSong)
                          ? "ic_32_heart_on"
                          : "ic_32_heart_off",
                      koreanNumberFormater(snapshot.data ?? 0),
                      onTap: () {
                        if (audioProvider.currentSong != null) {
                          var target = audioProvider.currentSong!;
                          keepModel.likes.contains(target)
                              ? {
                                  keepModel.removeLikeList(target),
                                  debounce.actionFunction(() {
                                    keepModel.removeLikeSong(target.id);
                                  })
                                }
                              : {
                                  keepModel.addLikeList(target),
                                  debounce.actionFunction(() {
                                    keepModel.addLikeSong(target.id);
                                  })
                                };
                        }
                      },
                      txtColor:
                          keepModel.likes.contains(audioProvider.currentSong)
                              ? WakColor.pink
                              : WakColor.grey400,
                    );
                  },
                ),
          playDetailBarBtn(
            "ic_32_views",
            koreanNumberFormater(audioProvider.currentSong == null
                ? 0
                : audioProvider.currentSong?.metadata.views ?? 0),
          ),
          playDetailBarBtn("ic_32_playadd_900", "노래담기", onTap: () async {
            if (keepModel.loginStatus == LoginStatus.before) {
              showModal(
                context: context,
                builder: (context) => const PopUp(
                  type: PopUpType.txtTwoBtn,
                  msg: '로그인이 필요한 서비스입니다.\n로그인 하시겠습니까?',
                ),
              ).then((value) {
                navProvider.update(4);
                Navigator.popUntil(context, (route) => route.isFirst);
              });
            } else {
              selProvider.addSong(audioProvider.currentSong!);
              Navigator.of(context, rootNavigator: true).push(
                  pageRouteBuilder(page: const KeepSongPopUp(), scope: null));
            }
          }),
          playDetailBarBtn(
            "ic_32_play_list",
            "재생목록",
            edgePadding: false,
            onTap: () {
              // ExitScope.add = ExitScope.playerPlaylist;
              FirebaseAnalytics.instance
                  .setCurrentScreen(screenName: 'playerPlaylist');
              Navigator.of(context, rootNavigator: true).push(
                  pageRouteBuilder(page: const PlayerPlayList(), scope: null));
            },
          )
        ],
      ),
    );
  }
}

class PlayerPlaylistBottom extends StatelessWidget {
  const PlayerPlaylistBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return Stack(
      children: [
        Container(
          height: 56,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 7, 7, 8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: loadImage(
                    audioProvider.currentSong?.id,
                    ThumbnailType.high,
                    borderRadius: 4,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      () {
                        switch (audioProvider.loopMode) {
                          case LoopMode.all:
                            return iconBtn("ic_32_repeat_on_all", onTap: () {
                              audioProvider.nextLoopMode();
                            });
                          case LoopMode.single:
                            return iconBtn("ic_32_repeat_on_1", onTap: () {
                              audioProvider.nextLoopMode();
                            });
                          default:
                            return iconBtn("ic_32_repeat_off", onTap: () {
                              audioProvider.nextLoopMode();
                            });
                        }
                      }(),
                      iconBtn("ic_32_prev_on", onTap: () {
                        audioProvider.toPrevious();
                      }),
                      audioProvider.playbackState == PlaybackState.playing
                          ? iconBtn("ic_32_stop", onTap: () {
                              audioProvider.pause();
                            })
                          : iconBtn("ic_32_play_900", onTap: () {
                              audioProvider.play();
                            }),
                      iconBtn("ic_32_next_on", onTap: () {
                        audioProvider.toNext();
                      }),
                      audioProvider.shuffle
                          ? iconBtn("ic_32_random_on", edgePadding: false,
                              onTap: () {
                              audioProvider.toggleShuffle();
                            })
                          : iconBtn("ic_32_random_off", edgePadding: false,
                              onTap: () {
                              audioProvider.toggleShuffle();
                            }),
                    ]),
              ),
            ],
          ),
        ),
        StreamBuilder(
          initialData: const Duration(),
          stream: audioProvider.position,
          builder: (context, snapshot) {
            return ProgressBar(
              progress: snapshot.data ?? const Duration(),
              total: audioProvider.duration,
              barHeight: 1,
              baseBarColor: WakColor.grey300,
              progressBarColor: WakColor.lightBlue,
              thumbRadius: 0,
              thumbColor: WakColor.lightBlue,
              timeLabelLocation: TimeLabelLocation.none,
              onSeek: (duration) {
                audioProvider.seek(duration.inSeconds.toDouble());
              },
            );
          },
        ),
      ],
    );
  }
}

class PlayerPlaylistSelBottom extends StatelessWidget {
  const PlayerPlaylistSelBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selNav = Provider.of<SelectSongProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final keepModel = Provider.of<KeepViewModel>(context);
    final navProvider = Provider.of<NavProvider>(context);
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
              selNav.selNum != audioProvider.queue.length
                  ? editBarBtn("ic_32_check_off", "전체선택", onTap: () {
                      selNav.addAllSong(audioProvider.queue);
                    })
                  : editBarBtn("ic_32_check_on", "전체선택해제",
                      onTap: selNav.clearList),
              editBarBtn("ic_32_playadd_25", "노래담기", onTap: () async {
                if (keepModel.loginStatus == LoginStatus.before) {
                  showModal(
                    context: context,
                    builder: (context) => const PopUp(
                      type: PopUpType.txtTwoBtn,
                      msg: '로그인이 필요한 서비스입니다.\n로그인 하시겠습니까?',
                    ),
                  ).then((value) {
                    navProvider.update(4);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                } else {
                  selNav.addSong(audioProvider.currentSong!);
                  Navigator.of(context, rootNavigator: true).push(
                    pageRouteBuilder(
                      page: const KeepSongPopUp(),
                      scope: null,
                    ),
                  );
                }
              }),
              editBarBtn("ic_32_delete", "삭제", onTap: () async {
                if (selNav.list.isNotEmpty) {
                  audioProvider
                      .removeQueueItems(selNav.list)
                      .then((value) => {selNav.clearList()});
                }
              }),
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

Widget getPlayerPlaylistBottom(BuildContext context) {
  final selNav = Provider.of<SelectSongProvider>(context);
  // print(selNav.selNum);
  if (selNav.selNum == 0) {
    return const PlayerPlaylistBottom();
  } else {
    return const PlayerPlaylistSelBottom();
  }
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
