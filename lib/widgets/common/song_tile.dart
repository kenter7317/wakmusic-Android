import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:lottie/lottie.dart';

import '../../models/providers/audio_provider.dart';

enum TileType {
  baseTile(
    showRank: false,
    showViews: false,
    showDate: false,
    canSelect: false,
    padding: {'start': 20, 'middle': 0, 'end': 20},
    icon: {},
  ),
  editTile(
    showRank: false,
    showViews: false,
    showDate: false,
    canSelect: true,
    padding: {'start': 20, 'middle': 16, 'end': 20},
    icon: {'icon': 'ic_32_move', 'size': 32.0},
  ),
  homeTile(
    showRank: true,
    showViews: false,
    showDate: false,
    canSelect: false,
    padding: {'start': 0, 'middle': 12, 'end': 0},
    icon: {'icon': 'ic_24_play_shadow', 'size': 24.0},
  ),
  nowPlayTile(
    showRank: false,
    showViews: false,
    showDate: false,
    canSelect: false,
    padding: {'start': 20, 'middle': 12, 'end': 16},
    icon: {'icon': 'wavestream', 'size': 32.0},
  ),
  canPlayTile(
    showRank: false,
    showViews: false,
    showDate: false,
    canSelect: false,
    padding: {'start': 20, 'middle': 16, 'end': 20},
    icon: {'icon': 'ic_32_play_point_shadow', 'size': 32.0},
  ),
  chartTile(
    showRank: true,
    showViews: true,
    showDate: false,
    canSelect: true,
    padding: {'start': 20, 'middle': 12, 'end': 20},
    icon: {},
  ),
  dateTile(
    showRank: false,
    showViews: false,
    showDate: true,
    canSelect: true,
    padding: {'start': 20, 'middle': 16, 'end': 20},
    icon: {},
  );

  const TileType({
    required this.showRank,
    required this.showViews,
    required this.showDate,
    required this.canSelect,
    required this.padding,
    required this.icon,
  });

  final bool showRank;
  final bool showViews;
  final bool showDate;
  final bool canSelect;
  final Map<String, double> padding;
  final Map<String, dynamic> icon;
}

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.tileType,
    this.rank = 0,
    this.idx = 0,
    this.onLongPress,
  });
  final Song? song;
  final TileType tileType;
  final int rank;
  final int idx;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (song == null) {
      return _buildSkeleton(context);
    } else {
      final selectedList = Provider.of<SelectSongProvider>(context);
      final viewModel = Provider.of<KeepViewModel>(context); /* for test */
      AudioProvider audioProvider = Provider.of<AudioProvider>(context);
      NavProvider navProvider = Provider.of<NavProvider>(context);
      bool isSelected = selectedList.list.contains(song);
      return GestureDetector(
        onTap: () {
          /*if (tileType.canSelect) {
            if (isSelected) {
              selectedList.removeSong(song!);
            } else {
              selectedList.addSong(song!);
            }
            /* for test */
            /*if (viewModel.loginStatus == LoginStatus.before) {
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
                    offset: const Offset(0.0, 1.0),
                  ),
                );
              }*/
          } else */
          if (tileType != TileType.nowPlayTile) {
            if (song != null) {
              audioProvider.addQueueItem(song!, autoplay: true);
              navProvider.subChange(1);
              navProvider.subSwitchForce(true);
            }
          }
        },
        onLongPress: () {
          if (onLongPress != null) {
            onLongPress!();
            HapticFeedback.lightImpact();
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
              tileType.padding['start']!, 0, tileType.padding['end']!, 0),
          color: (tileType.canSelect && isSelected)
              ? WakColor.grey200
              : (tileType == TileType.editTile)
                  ? WakColor.grey100
                  : Colors.transparent,
          child: SizedBox(
            height: (tileType == TileType.homeTile) ? 42 : 60,
            child: Row(
              children: [
                if (tileType.showRank) _buildRank(context),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: (tileType == TileType.homeTile) ? 1 : 10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ExtendedImage.network(
                      'https://i.ytimg.com/vi/${song!.id}/hqdefault.jpg',
                      fit: BoxFit.cover,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState !=
                            LoadState.completed) {
                          return Image.asset(
                            'assets/images/img_40_thumbnail.png',
                            fit: BoxFit.cover,
                          );
                        }
                        return null;
                      },
                      cacheMaxAge: const Duration(days: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Text(
                          song!.title,
                          style: WakText.txt14MH.copyWith(
                            color: (tileType == TileType.nowPlayTile)
                                ? WakColor.lightBlue
                                : WakColor.grey900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                        child: Text(
                          song!.artist,
                          style: WakText.txt12L.copyWith(
                            color: (tileType == TileType.nowPlayTile)
                                ? WakColor.lightBlue
                                : WakColor.grey900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tileType.padding['middle']),
                if (tileType.showViews)
                  Text(
                    NumberFormat('###,###,###회').format(song!.display),
                    style: WakText.num12L,
                    textAlign: TextAlign.right,
                  ),
                if (tileType.showDate)
                  Text(
                    (song!.date != DateTime(1999))
                        ? DateFormat('yyyy.MM.dd').format(song!.date)
                        : '-',
                    style: WakText.num12L,
                    textAlign: TextAlign.right,
                  ),
                if (!tileType.canSelect && tileType != TileType.baseTile)
                  (tileType != TileType.nowPlayTile)
                      ? GestureDetector(
                          onTap: () {
                            audioProvider.addQueueItem(song!, autoplay: true);
                            navProvider.subChange(1);
                            navProvider.subSwitchForce(true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: WakColor.dark.withOpacity(0.04),
                                  blurRadius: tileType.icon['size'] / 6,
                                  offset: Offset(0, tileType.icon['size'] / 6),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/${tileType.icon['icon']}.svg',
                              width: tileType.icon['size'],
                              height: tileType.icon['size'],
                            ),
                          ),
                        )
                      : Lottie.asset(
                          'assets/lottie/${tileType.icon['icon']}.json',
                          width: tileType.icon['size'],
                          height: tileType.icon['size'],
                        ),
                if (tileType == TileType.editTile)
                  ReorderableDragStartListener(
                    index: idx,
                    child: SvgPicture.asset(
                      'assets/icons/${tileType.icon['icon']}.svg',
                      width: tileType.icon['size'],
                      height: tileType.icon['size'],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRank(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 28,
        height: 40,
        child: Column(
          children: [
            SizedBox(
              child: Text(
                rank.toString(),
                style: WakText.txt16M,
                textAlign: TextAlign.center,
              ),
            ),
            _rankChange(context),
          ],
        ),
      ),
    );
  }

  Widget _rankChange(BuildContext context) {
    int diff = song!.metadata.last! - rank;
    /* NEW */
    if (song!.metadata.last == 0) {
      return Text(
        'NEW',
        style: WakText.txt11M.copyWith(color: WakColor.orange),
        textAlign: TextAlign.center,
      );
    }
    /* BLOW UP */
    else if (diff > 99) {
      return Container(
        height: 16,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/ic_12_blowup.svg',
          width: 12,
          height: 12,
        ),
      );
    }
    /* ZERO */
    else if (diff == 0) {
      return Container(
        height: 16,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          'assets/icons/ic_12_zero.svg',
          width: 12,
          height: 12,
        ),
      );
    }
    /* UP or DOWN */
    else {
      Color color = (diff > 0) ? WakColor.pink : WakColor.blue;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/ic_12_${(diff > 0) ? 'up' : 'down'}.svg',
            width: 12,
            height: 12,
          ),
          SizedBox(
            width: 14,
            child: Text(
              diff.abs().toString(),
              style: WakText.txt11M.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          tileType.padding['start']!, 0, tileType.padding['end']!, 0),
      child: SizedBox(
        height: (tileType == TileType.homeTile) ? 42 : 60,
        child: Row(
          children: [
            if (tileType.showRank)
              SkeletonBox(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 28,
                    height: 40,
                    color: WakColor.grey200,
                  ),
                ),
              ),
            SkeletonBox(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: (tileType == TileType.homeTile) ? 1 : 10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: WakColor.grey200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(wakTxtStyle: WakText.txt14MH),
                  SkeletonText(wakTxtStyle: WakText.txt12L),
                ],
              ),
            ),
            SizedBox(width: tileType.padding['middle']),
            if (tileType.showViews)
              SkeletonText(wakTxtStyle: WakText.txt12L, width: 75),
            if (tileType.showDate)
              SkeletonText(wakTxtStyle: WakText.txt12L, width: 60),
            if (!tileType.canSelect || tileType == TileType.editTile)
              SkeletonBox(
                child: Container(
                  width: tileType.icon['size'],
                  height: tileType.icon['size'],
                  decoration: const BoxDecoration(
                    color: WakColor.grey200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
