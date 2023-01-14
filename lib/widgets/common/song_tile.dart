import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';

enum TileType {
  baseTile(false, false, false, true, {'start': 20, 'middle': 16, 'end': 20}, {}),
  homeTile(true, false, false, false, {'start': 0, 'middle': 12, 'end': 0}, {'icon': 'ic_24_play_shadow', 'width': 24.0, 'height': 24.0}),
  nowPlayTile(false, false, false, false, {'start': 20, 'middle': 12, 'end': 16}, {'icon': 'logo_00', 'width': 40.0, 'height': 26.0}),
  canPlayTile(false, false, false, false, {'start': 20, 'middle': 16, 'end': 20}, {'icon': 'ic_32_play_point_shadow', 'width': 32.0, 'height': 32.0}),
  chartTile(true, true, false, true, {'start': 20, 'middle': 12, 'end': 20}, {}),
  dateTile(false, false, true, true, {'start': 20, 'middle': 16, 'end': 20}, {});

  const TileType(this.showRank, this.showViews, this.showDate, this.canSelect,
      this.padding, this.icon);
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
  });
  final Song song;
  final TileType tileType;
  final int rank;

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /* for test */
        String title = '플레이리스트 01';
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => BotSheet(
            type: BotSheetType.editList,
            initialValue: title,
          ),
        );
        if (widget.tileType.canSelect) {
          /* select <-> unselect */
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(widget.tileType.padding['start']!, 0, widget.tileType.padding['end']!, 0),
        color: widget.tileType.canSelect /* && isSelected */
            ? WakColor.grey200 : Colors.transparent,
        child: SizedBox(
          height: widget.tileType == TileType.homeTile ? 42 : 60,
          child: Row(
            children: [
              if (widget.tileType.showRank) _buildRank(context),
              if (widget.tileType.showRank) const SizedBox(width: 8),
              ExtendedImage.network(
                'https://i.ytimg.com/vi/${widget.song.id}/hqdefault.jpg',
                fit: BoxFit.cover,
                width: 72,
                height: 40,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState != LoadState.completed) {
                    return Image.asset("assets/images/img_40_thumbnail.png");
                  }
                }
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
                        widget.song.title,
                        style: WakText.txt14MH.copyWith(
                          color: widget.tileType == TileType.nowPlayTile
                              ? WakColor.lightBlue
                              : WakColor.grey900,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                      child: Text(
                        widget.song.artist,
                        style: WakText.txt12L.copyWith(
                          color: widget.tileType == TileType.nowPlayTile
                              ? WakColor.lightBlue
                              : WakColor.grey900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: widget.tileType.padding['middle']),
              if (widget.tileType.showViews)
                Text(
                  NumberFormat('###,###,###회').format(widget.song.views),
                  style: WakText.txt12L.copyWith(color: WakColor.grey900),
                  textAlign: TextAlign.right,
                ),
              if (widget.tileType.showDate)
                Text(
                  DateFormat('yyyy.MM.dd').format(widget.song.date),
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
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/${widget.tileType.icon['icon']}.svg', 
                          width: widget.tileType.icon['width'],
                          height: widget.tileType.icon['height'],
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/icons/${widget.tileType.icon['icon']}.png',
                      width: widget.tileType.icon['width'],
                        height: widget.tileType.icon['height'],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRank(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 40,
      child: Column(
        children: [
          Text(
            widget.rank.toString(),
            style: WakText.txt16M.copyWith(color: WakColor.grey900),
            textAlign: TextAlign.center,
          ),
          _rankChange(context),
        ],
      ),
    );
  }

  Widget _rankChange(BuildContext context) {
    int diff = widget.song.last - widget.rank;
    /* NEW */
    if (widget.song.last == 0) {
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
      Color color = diff > 0 ? WakColor.pink : WakColor.blue;
      return Row(
        children: [
          SvgPicture.asset(
            'assets/icons/ic_12_${diff > 0 ? 'up' : 'down'}.svg',
            width: 12,
            height: 12,
          ),
          SizedBox(
            width: 12,
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
}
