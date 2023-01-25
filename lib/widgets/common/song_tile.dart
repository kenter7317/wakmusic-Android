import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:lottie/lottie.dart';

enum TileType {
  editTile(false, false, false, true,
    {'start': 20, 'middle': 16, 'end': 20}, 
    {'icon': 'ic_32_move', 'size': 32.0}),
  homeTile(true, false, false, false,
    {'start': 0, 'middle': 12, 'end': 0},
    {'icon': 'ic_24_play_shadow', 'size': 24.0}),
  nowPlayTile(false, false, false, false,
    {'start': 20, 'middle': 12, 'end': 16},
    {'icon': 'WaveStream', 'size': 32.0}),
  canPlayTile(false, false, false, false,
    {'start': 20, 'middle': 16, 'end': 20},
    {'icon': 'ic_32_play_point_shadow', 'size': 32.0}),
  chartTile(true, true, false, true,
    {'start': 20, 'middle': 12, 'end': 20}, {}),
  dateTile(false, false, true, true,
    {'start': 20, 'middle': 16, 'end': 20}, {});

  const TileType(
    this.showRank,
    this.showViews,
    this.showDate,
    this.canSelect,
    this.padding,
    this.icon,
  );
  final bool showRank;
  final bool showViews;
  final bool showDate;
  final bool canSelect;
  final Map<String, double> padding;
  final Map<String, dynamic> icon;
}

class SongTile extends StatefulWidget {
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
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.song == null) {
      return _buildSkeleton(context);
    } else {
      SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
      bool isSelected = selectedList.list.contains(widget.song);
      return GestureDetector(
        onTap: () {
          if (widget.tileType.canSelect) {
            if (isSelected) {
              selectedList.removeSong(widget.song!);
            } else {
              selectedList.addSong(widget.song!);
            }
          } else if (widget.tileType != TileType.nowPlayTile){
            /* play song */
          }
        },
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress!();
            HapticFeedback.lightImpact();
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(widget.tileType.padding['start']!, 0, widget.tileType.padding['end']!, 0),
          color: (widget.tileType.canSelect && isSelected) 
            ? WakColor.grey200
            : (widget.tileType == TileType.editTile)
              ? WakColor.grey100
              : Colors.transparent,
          child: SizedBox(
            height: (widget.tileType == TileType.homeTile) ? 42 : 60,
            child: Row(
              children: [
                if (widget.tileType.showRank) _buildRank(context),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: (widget.tileType == TileType.homeTile) ? 1 : 10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ExtendedImage.network(
                      'https://i.ytimg.com/vi/${widget.song!.id}/hqdefault.jpg',
                      fit: BoxFit.cover,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4),
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState != LoadState.completed) {
                          return Image.asset(
                            'assets/images/img_40_thumbnail.png',
                            fit: BoxFit.cover,
                          );
                        }
                        return null;
                      },
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
                          widget.song!.title,
                          style: WakText.txt14MH.copyWith(
                            color: (widget.tileType == TileType.nowPlayTile) ? WakColor.lightBlue : WakColor.grey900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                        child: Text(
                          widget.song!.artist,
                          style: WakText.txt12L.copyWith(
                            color: (widget.tileType == TileType.nowPlayTile) ? WakColor.lightBlue : WakColor.grey900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: widget.tileType.padding['middle']),
                if (widget.tileType.showViews)
                  Text(
                    NumberFormat('###,###,###회').format(widget.song!.views),
                    style: WakText.txt12L.copyWith(color: WakColor.grey900),
                    textAlign: TextAlign.right,
                  ),
                if (widget.tileType.showDate)
                  Text(
                    (widget.song!.date != DateTime(1999))
                      ? DateFormat('yyyy.MM.dd').format(widget.song!.date)
                      : '-',
                    style: WakText.txt12L.copyWith(color: WakColor.grey900),
                    textAlign: TextAlign.right,
                  ),
                if (!widget.tileType.canSelect)
                  (widget.tileType != TileType.nowPlayTile)
                    ? GestureDetector(
                        onTap: () {
                          /* play song */
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: WakColor.dark.withOpacity(0.04),
                                blurRadius: widget.tileType.icon['size'] / 6,
                                offset: Offset(0, widget.tileType.icon['size'] / 6),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/${widget.tileType.icon['icon']}.svg',
                            width: widget.tileType.icon['size'],
                            height: widget.tileType.icon['size'],
                          ),
                        ),
                      )
                    : Lottie.asset(
                        'assets/lottie/${widget.tileType.icon['icon']}.json',
                        width: widget.tileType.icon['size'],
                        height: widget.tileType.icon['size'],
                      ),
                if (widget.tileType == TileType.editTile)
                  ReorderableDragStartListener(
                    index: widget.idx,
                    child: SvgPicture.asset(
                      'assets/icons/${widget.tileType.icon['icon']}.svg',
                      width: widget.tileType.icon['size'],
                      height: widget.tileType.icon['size'],
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
      padding: const EdgeInsets.only(right: 6),
      child: SizedBox(
        width: 26,
        height: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                widget.rank.toString(),
                style: WakText.txt16M.copyWith(color: WakColor.grey900),
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
    int diff = widget.song!.last - widget.rank;
    /* NEW */
    if (widget.song!.last == 0) {
      return SizedBox(
        width: 24,
        child: Text(
          'NEW',
          style: WakText.txt11M.copyWith(color: WakColor.orange),
          textAlign: TextAlign.center,
        ),
      );
    }
    /* BLOW UP */
    else if (diff > 99) {
      return Container(
        width: 24,
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
        width: 24,
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
      padding: EdgeInsets.fromLTRB(widget.tileType.padding['start']!, 0, widget.tileType.padding['end']!, 0),
      child: SizedBox(
        height: (widget.tileType == TileType.homeTile) ? 42 : 60,
        child: Row(
          children: [
            if (widget.tileType.showRank)
              SkeletonBox(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 26,
                    height: 40,
                    color: WakColor.grey200,
                  ),
                ),
              ),
            SkeletonBox(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: (widget.tileType == TileType.homeTile) ? 1 : 10),
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
            SizedBox(width: widget.tileType.padding['middle']),
            if (widget.tileType.showViews)
              SkeletonText(wakTxtStyle: WakText.txt12L, width: 75),
            if (widget.tileType.showDate)
              SkeletonText(wakTxtStyle: WakText.txt12L, width: 60),
            if (!widget.tileType.canSelect || widget.tileType == TileType.editTile)
              SkeletonBox(
                child: Container(
                  width: widget.tileType.icon['size'],
                  height: widget.tileType.icon['size'],
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
