import 'package:audio_service/models/enums.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models/providers/tab_provider.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/screens/artists/artists_view_model.dart';
import 'package:wakmusic/screens/charts/charts_view_model.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/player/player_playlist_view.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart' as playlist;
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/utils/load_image.dart';
import 'package:wakmusic/utils/number_format.dart';
import 'package:wakmusic/widgets/common/keep_song_pop_up.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:wakmusic/widgets/show_modal.dart';

import '../../screens/player/player_view.dart';
import '../page_route_builder.dart';

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
      editBar(context, EditBarType.keepProfileBar),
      editBar(context, EditBarType.searchBar)
    ];
    return barList[botNav.subIdx];
  }

  /* 임시 노래재생상세 바 */
  Widget playDetailBar() {
    final botNav = Provider.of<NavProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
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
              ? playDetailBarBtn(
                  "ic_32_heart_on",
                  koreanNumberFormater(audioProvider.currentSong == null
                      ? 0
                      : audioProvider
                          .currentSong!.metadata.last!), // 수정(좋아요 연결 필요)
                  txtColor: WakColor.pink, onTap: () {
                  setState(() {
                    tempLike = !tempLike;
                  });
                })
              : playDetailBarBtn(
                  "ic_32_heart_off",
                  koreanNumberFormater(audioProvider.currentSong == null
                      ? 0
                      : audioProvider.currentSong!.metadata.last!), onTap: () {
                  setState(() {
                    tempLike = !tempLike;
                  });
                }), // 수정 (좋아요 상태 연결)
          playDetailBarBtn(
            "ic_32_views",
            koreanNumberFormater(audioProvider.currentSong == null
                ? 0
                : audioProvider.currentSong!.metadata.views),
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
                builder: (context) => const PlayerPlayList(),
              ),
            );
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
    final audioProvider = Provider.of<AudioProvider>(context);
    return GestureDetector(
      onTap: () {
        if (type == PlayerBarType.main) {
          // ExitScope.add = ExitScope.player;
          Navigator.of(context, rootNavigator: true)
              .push(pageRouteBuilder(page: const Player(), scope: null));
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
                    child: loadImage(
                      audioProvider.currentSong?.id,
                      ThumbnailType.high,
                      borderRadius: 4,
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
                                    audioProvider.currentSong == null
                                        ? "노래 없음"
                                        : audioProvider.currentSong!.title,
                                    style: WakText.txt14MH
                                        .copyWith(color: WakColor.grey900),
                                  ),
                                  Text(
                                    audioProvider.currentSong == null
                                        ? "노래 없음"
                                        : audioProvider.currentSong!.artist,
                                    style: WakText.txt12L
                                        .copyWith(color: WakColor.grey900),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            audioProvider.playbackState == PlaybackState.playing
                                ? iconBtn("ic_32_stop", edgePadding: true,
                                    onTap: () {
                                    setState(() {
                                      audioProvider.pause();
                                    });
                                  })
                                : iconBtn("ic_32_play_900", edgePadding: true,
                                    onTap: () {
                                    setState(() {
                                      audioProvider.play();
                                    });
                                  }),
                            iconBtn("ic_32_close", edgePadding: false,
                                onTap: () {
                              botNav.subSwitch();
                              audioProvider.stop();
                              audioProvider.clear();
                            }),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            () {
                              switch (audioProvider.loopMode) {
                                case LoopMode.all:
                                  return iconBtn("ic_32_repeat_on_all",
                                      onTap: () {
                                    audioProvider.nextLoopMode();
                                  });
                                case LoopMode.single:
                                  return iconBtn("ic_32_repeat_on_1",
                                      onTap: () {
                                    audioProvider.nextLoopMode();
                                  });
                                default:
                                  return iconBtn("ic_32_repeat_off", onTap: () {
                                    setState(() {
                                      audioProvider.nextLoopMode();
                                    });
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
                                ? iconBtn("ic_32_random_on", edgePadding: true,
                                    onTap: () {
                                    audioProvider.toggleShuffle();
                                  })
                                : iconBtn("ic_32_random_off", edgePadding: true,
                                    onTap: () {
                                    audioProvider.toggleShuffle();
                                  }),
                          ],
                        ),
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
    final navProvider = Provider.of<NavProvider>(context);
    final selProvider = Provider.of<SelectSongProvider>(context);
    final selListProvider = Provider.of<SelectPlaylistProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);
    final keepViewModel = Provider.of<KeepViewModel>(context);
    final playListViewModel = Provider.of<playlist.PlaylistViewModel>(context);
    final chartViewModel = Provider.of<ChartsViewModel>(context);
    final artistViewModel = Provider.of<ArtistsViewModel>(context);
    final tabProvider = Provider.of<TabProvider>(context);

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
                selProvider.selNum != selProvider.maxSel
                    ? editBarBtn(
                        "ic_32_check_off",
                        "전체선택",
                        onTap: () async {
                          switch (navProvider.curIdx) {
                            case 1:
                              List<Song>? songlist = await chartViewModel
                                  .charts[ChartType.values[tabProvider.curIdx]];
                              selProvider.addAllSong(
                                  songlist!.whereType<Song>().toList(),
                                  del: true);
                              break;
                            case 3:
                              selProvider.addAllSong(artistViewModel
                                  .albums[AlbumType.values[tabProvider.curIdx]]!
                                  .whereType<Song>()
                                  .toList());
                              break;
                            default:
                              selProvider.addAllSong(playListViewModel.tempsongs
                                  .whereType<Song>()
                                  .toList());
                              break;
                          }
                        },
                      )
                    : editBarBtn("ic_32_check_on", "전체선택해제", onTap: () {
                        selProvider.clearList();
                        if (audioProvider.isEmpty) {
                          navProvider.subSwitchForce(false);
                        } else {
                          navProvider.subChange(1);
                        }
                      }),
              if (type.showSongAdd)
                editBarBtn(
                  "ic_32_playadd_25",
                  "노래담기",
                  onTap: () {
                    if (keepViewModel.loginStatus == LoginStatus.before) {
                      selProvider.clearList();
                      if (audioProvider.isEmpty) {
                        navProvider.subSwitchForce(false);
                      } else {
                        navProvider.subChange(1);
                      }
                      showModal(
                        context: context,
                        builder: (context) => PopUp(
                          type: PopUpType.txtOneBtn,
                          msg: '로그인이 필요한 기능입니다.',
                          posFunc: () => navProvider.update(4),
                        ),
                      );
                    } else {
                      Navigator.of(context, rootNavigator: true).push(
                        pageRouteBuilder(
                          page: const KeepSongPopUp(),
                          scope: null,
                        ),
                      );
                    }
                  },
                ),
              if (type.showPlayListAdd)
                editBarBtn("ic_32_play_add", "재생목록추가", onTap: () async {
                  if (selProvider.list.isNotEmpty) {
                    audioProvider.addQueueItems(
                      selProvider.list,
                    );
                    selProvider.clearList();
                  } else {
                    for (var i = 0; i < selListProvider.list.length; i++) {
                      audioProvider
                          .addQueueItems(selListProvider.list[i].songs);
                    }
                    selListProvider.clearList();
                  }
                  navProvider.subChange(1);
                }),
              if (type.showPlay)
                editBarBtn("ic_32_play_25", "재생", onTap: () {
                  if (selProvider.list.length == 1) {
                    if (audioProvider.queue.contains(selProvider.list[0])) {
                      audioProvider.toQueueItem(
                          audioProvider.queue.indexOf(selProvider.list[0]));
                    } else {
                      audioProvider.addQueueItem(selProvider.list[0],
                          autoplay: true);
                    }
                  } else {
                    if (audioProvider.queue
                        .toSet()
                        .containsAll(selProvider.list)) {
                      showToastWidget(
                        context: context,
                        position: const StyledToastPosition(
                          align: Alignment.bottomCenter,
                          offset: 56,
                        ),
                        animation: StyledToastAnimation.slideFromBottomFade,
                        reverseAnimation: StyledToastAnimation.fade,
                        const ToastMsg(msg: '이미 재생목록에 담긴 곡들입니다.'),
                      );
                    } else {
                      audioProvider.addQueueItems(
                        selProvider.list,
                        autoplay: true,
                      );
                    }
                  }
                  selProvider.clearList();
                  navProvider.subChange(1);
                }),
              if (type.showDelete)
                editBarBtn("ic_32_delete", "삭제", onTap: () {
                  if (selProvider.list.isNotEmpty) {
                    if (playListViewModel.curStatus ==
                        playlist.EditStatus.editing) {
                      playListViewModel.removeSongs(selProvider.list);
                    } else {
                      keepViewModel.deleteLikeSongs(selProvider.list);
                    }
                    if (audioProvider.isEmpty) {
                      navProvider.subSwitchForce(false);
                    } else {
                      navProvider.subChange(1);
                    }
                  } else {
                    for (var list in selListProvider.list) {
                      keepViewModel.removeList(list);
                    }
                    if (audioProvider.isEmpty) {
                      navProvider.subSwitchForce(false);
                    } else {
                      navProvider.subChange(1);
                    }
                  }
                }),
              if (type.showEdit)
                editBarBtn("ic_32_edit", "편집", onTap: () {
                  ExitScope.add = ExitScope.editMode;
                  playListViewModel.updateStatus(playlist.EditStatus.editing);
                  if (audioProvider.isEmpty) {
                    navProvider.subSwitchForce(false);
                  } else {
                    navProvider.subChange(1);
                  }
                }),
              if (type.showShare)
                editBarBtn("ic_32_share-1", "공유하기", onTap: () async {
                  await showModal(
                    context: context,
                    builder: (_) => BotSheet(
                      type: BotSheetType.shareList,
                      initialValue: playListViewModel.prevKeyword.toString(),
                    ),
                  );
                  if (audioProvider.isEmpty) {
                    navProvider.subSwitchForce(false);
                  } else {
                    navProvider.subChange(1);
                  }
                }),
              if (type.showProfileChange)
                editBarBtn("ic_32_profile", "프로필 변경", onTap: () async {
                  keepViewModel.updateUserProfile(await showModal(
                    context: context,
                    builder: (_) => BotSheet(
                      type: BotSheetType.selProfile,
                      initialValue: keepViewModel.user.profile.type,
                      profiles: keepViewModel.profiles,
                    ),
                  ));
                  if (audioProvider.isEmpty) {
                    navProvider.subSwitchForce(false);
                  } else {
                    navProvider.subChange(1);
                  }
                }),
              if (type.showNicknameChange)
                editBarBtn("ic_32_edit", "닉네임 수정", onTap: () async {
                  keepViewModel.updateUserName(await showModal(
                    context: context,
                    builder: (_) => BotSheet(
                      type: BotSheetType.editName,
                      initialValue: keepViewModel.user.displayName,
                    ),
                  ));
                  if (audioProvider.isEmpty) {
                    navProvider.subSwitchForce(false);
                  } else {
                    navProvider.subChange(1);
                  }
                })
            ],
          ),
        ),
        if (selProvider.selNum > 0)
          Positioned(
            top: -16,
            left: 20 - (selProvider.selNum.toString().length - 1) * 4,
            child: Container(
              height: 32,
              width: 32 + (selProvider.selNum.toString().length - 1) * 8,
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
                selProvider.selNum.toString(),
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
  keepListBar(true, false, true, true, false, false, false, false, false),
  keepProfileBar(false, false, false, false, false, false, false, true, true),
  searchBar(false, true, true, false, true, false, false, false, false);

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
