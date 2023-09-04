import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/screens/player/player_view_model.dart';
import 'package:wakmusic/services/debounce.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/utils/load_image.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/player/player_bottom.dart';
import 'package:wakmusic/widgets/player/player_button.dart';

import '../../models/providers/audio_provider.dart';
import '../../models/providers/nav_provider.dart';
import '../../models_v2/song.dart';
import '../../style/text_styles.dart';
import '../../widgets/player/player_scroll_snap_list.dart';

class Player extends StatelessWidget {
  const Player({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WakColor.grey100,
        body: Exitable(
          scopes: const [ExitScope.player],
          onExitable: (scope) {
            // if (scope == ExitScope.player) {
            //   final botNav = Provider.of<NavProvider>(context, listen: false);
            //   botNav.mainSwitchForce(true);
            //   botNav.subSwitchForce(true);
            //   botNav.subChange(1);
            //   ExitScope.remove = ExitScope.player;
            //   Navigator.pop(context);
            // }
          },
          child: WillPopScope(
            onWillPop: () async {
              final botNav = Provider.of<NavProvider>(context, listen: false);
              botNav.mainSwitchForce(true);
              botNav.subSwitchForce(true);
              botNav.subChange(1);
              FirebaseAnalytics.instance
                  .setCurrentScreen(screenName: AppScreen.name(botNav.curIdx));
              return true;
            },
            child: _buildBody(context),
          ),
        ),
        bottomNavigationBar: const PlayerViewBottom(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    var statusHeight = MediaQuery.of(context).padding.top;
    var height = MediaQuery.of(context).size.height - statusHeight;
    var width = MediaQuery.of(context).size.width;

    var blank = 0;
    if (height >= 732) {
      blank = ((height - (width - 50) / (16 / 9) - 334 - 12) / 20).floor();
    } else {
      blank = ((height - (width - 50) / (16 / 9) - 286 - 12) / 20).floor();
    }

    return Stack(
      children: [
        Positioned(
          child: Align(
            alignment: Alignment.topCenter,
            child: Selector<AudioProvider, String>(
              selector: (context, provider) => provider.currentSong?.id ?? '',
              builder: (context, id, _) {
                //print("back id : $id");
                return Container(
                  height: statusHeight +
                      48 +
                      ((width - 50) / (16 / 9)) +
                      (blank * 4 + 12) -
                      36,
                  width: width * 1.44,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: loadImage(id, ThumbnailType.high).image,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.6),
                        BlendMode.dstATop,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 200,
                        sigmaY: 200,
                      ),
                      child: Container(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        _buildPlayer(context, blank),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context, int blank) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        _buildTitle(context),
        SizedBox(height: blank * 4 + 12),
        _buildAlbumImage(context),
        SizedBox(height: blank * 4 - 4),
        _buildLyrics(context),
        SizedBox(height: blank * 4),
        _buildAudioProgressBar(context),
        SizedBox(height: blank * 4),
        const PlayerButton(),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    NavProvider botNav = Provider.of<NavProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
          child: GestureDetector(
            onTap: () {
              botNav.mainSwitchForce(true);
              botNav.subSwitchForce(true);
              botNav.subChange(1);
              // ExitScope.remove = ExitScope.player;
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              'assets/icons/ic_32_arrow_bottom.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Selector<AudioProvider, Song?>(
              selector: (context, audioProvider) => audioProvider.currentSong,
              builder: (context, currentSong, _) {
                //print( "title and artist : ${currentSong.title} & ${currentSong.artist}");
                return Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: AutoSizeText(
                        currentSong?.title.toString() ?? '재생중인 곡이 없습니다.',
                        maxLines: 1,
                        style: WakText.txt16M,
                        overflowReplacement: Marquee(
                          text: currentSong?.title.toString() ?? '재생중인 곡이 없습니다.',
                          style: WakText.txt16M,
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 20.0,
                          velocity: 20.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          showFadingOnlyWhenScrolling: false,
                          fadingEdgeEndFraction: 0.1,
                          fadingEdgeStartFraction: 0.1,
                        ),
                      )
                    ),
                    SizedBox(
                      height: 20,
                      child: AutoSizeText(
                        currentSong?.artist.toString() ?? '',
                        maxLines: 1,
                        style: WakText.txt14M
                            .copyWith(color: WakColor.grey900.withOpacity(0.6)),
                        overflowReplacement: Marquee(
                          text: currentSong?.artist.toString() ?? '',
                          style: WakText.txt14M
                              .copyWith(color: WakColor.grey900.withOpacity(0.6)),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 20.0,
                          velocity: 20.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          showFadingOnlyWhenScrolling: false,
                          fadingEdgeEndFraction: 0.1,
                          fadingEdgeStartFraction: 0.1,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 20, 0),
          child: SizedBox(width: 32, height: 32,)
        ),
      ],
    );
  }

  Widget _buildAlbumImage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Selector<AudioProvider, String>(
          selector: (context, provider) => provider.currentSong?.id ?? '',
          builder: (context, id, _) {
            // log("song img : $id");
            return loadImage(id, ThumbnailType.max, borderRadius: 12);
          },
        ),
      ),
    );
  }

  Widget _buildLyrics(BuildContext context) {
    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    final controller = ScrollController();
    return Container(
      alignment: Alignment.center,
      height: height >= 732 ? 120 : 72,
      width: MediaQuery.of(context).size.width * 0.75, // = 270/360
      child: Selector<AudioProvider, Song?>(
        selector: (context, audioProvider) => audioProvider.currentSong,
        builder: (context, currentSong, _) {
          PlayerViewModel viewModel = Provider.of<PlayerViewModel>(context);
          viewModel.getLyrics(currentSong?.id ?? '');
          controller.addListener(() {
            if (controller.position.userScrollDirection !=
                ScrollDirection.idle) {
              viewModel.updateScrollState(ScrollState.scrolling);
            } else {
              viewModel.updateScrollState(ScrollState.notScrolling);
            }
          });

          return FutureBuilder(
            future: viewModel.lyrics,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.connectionState == ConnectionState.done &&
                  (snapshot.data?.subtitles.isNotEmpty ?? false)) {
                final audioProvider = Provider.of<AudioProvider>(context);
                final lyrics = snapshot.data!;
                return StreamBuilder(
                  stream: audioProvider.position,
                  builder: (context, position) {
                    var current = lyrics.durationSearch(
                        (currentSong?.start ?? Duration.zero) +
                            (position.data ?? Duration.zero));
                    var nowIndex = (current != null)
                        ? lyrics.subtitles.indexOf(current)
                        : 0;
                    if (position.hasData) {
                      Future.microtask(() {
                        if (controller.position.userScrollDirection ==
                            ScrollDirection.idle) {
                          var curr = lyrics.durationSearch(
                              (currentSong?.start ?? Duration.zero) +
                                  (position.data ?? Duration.zero));
                          if (curr == null) {
                            return;
                          }
                          var now = lyrics.subtitles.indexOf(curr);
                          if (now < 0) {
                            return;
                          }
                          viewModel.scrollSnapListKey.currentState
                              ?.focusToItem(now);
                        }
                      });
                    }

                    return PlayerScrollSnapList(
                      key: viewModel.scrollSnapListKey,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      onItemFocus: (idx) async {
                        if (nowIndex != idx) {
                          audioProvider.seek(
                            lyrics.subtitles[idx].start.inMilliseconds / 1000,
                          );
                        }
                      },
                      itemSize: 24,
                      //dynamicItemSize: true,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 24 * lyrics.subtitles[index].data.split('\n').length.toDouble(),
                          alignment: Alignment.center,
                          child: Text(
                            _lyricsFormat(lyrics.subtitles[index].data),
                            style: WakText.txt14MH.copyWith(
                              color: index == nowIndex
                                  ? WakColor.lightBlue
                                  : WakColor.grey500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      positionList: _calcPositionList(lyrics.subtitles),
                      itemCount: lyrics.subtitles.length,
                      listController: controller,
                    );
                  },
                );
              }

              return Text(
                '가사가 존재하지 않습니다',
                style: WakText.txt14MH.copyWith(color: WakColor.grey500),
                textAlign: TextAlign.center,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAudioProgressBar(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final currentSong = audioProvider.currentSong;
    final debounce = new Debounce();
    return StreamBuilder(
      initialData: const Duration(),
      stream: audioProvider.position,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ProgressBar(
                progress: snapshot.data ?? const Duration(),
                total: audioProvider.duration,
                barHeight: 2,
                baseBarColor: WakColor.grey300,
                progressBarColor: WakColor.lightBlue,
                thumbRadius: 4,
                thumbColor: WakColor.lightBlue,
                timeLabelLocation: TimeLabelLocation.none,
                onSeek: (duration) {
                  if (currentSong != null) {
                    audioProvider.seek(
                        (duration + (currentSong.start)).inSeconds.toDouble());
                  }
                },
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(snapshot.data ?? Duration.zero),
                    style: WakText.txt12MH.copyWith(color: WakColor.lightBlue),
                  ),
                  Text(
                    _format(audioProvider.duration),
                    style: WakText.txt12MH.copyWith(color: WakColor.grey400),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _lyricsFormat(String data) {
    return data;
  }

  String _format(Duration duration) {
    String h = duration.inHours > 0 ? '${duration.inHours}:' : '';
    String m = intl.NumberFormat(h.isEmpty ? '#0:' : '00:')
        .format(duration.inMinutes % 60);
    String s = intl.NumberFormat('00').format(duration.inSeconds % 60);
    return '$h$m$s';
  }

  List<int> _calcPositionList(List<Subtitle> subList){
    List<int> list = List.empty(growable: true);

    for (var sub in subList) {
      if(list.isEmpty) { list.add(0); }
      else { list.add(list.last + 24 * sub.data.split('\n').length); }
    }

    return list;
  }
}
