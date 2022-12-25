import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:intl/intl.dart';

enum TileType {
  baseTile(false, false, false, true, 60, null),
  homeTile(true, false, false, false, 12, Icon(Icons.play_circle_fill_rounded, size: 24,)),
  nowPlayTile(false, false, false, false, 56, Icon(Icons.rectangle_rounded, size: 40,)),
  canPlayTile(false, false, false, false, 60, Icon(Icons.play_circle_fill_rounded, size: 32,)),
  chartTile(true, true, false, true, 12, null),
  dateTile(false, false, true, true, 39, null);

  const TileType(this.showRank, this.showViews, this.showDate, this.canSelect,
      this.padding, this.icon);
  final bool showRank;
  final bool showViews;
  final bool showDate;
  final bool canSelect;
  final double padding;
  final Icon? icon;
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
        if (widget.tileType.canSelect) {
          /* */
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 0, widget.tileType == TileType.nowPlayTile ? 16 : 20, 0),
        color: widget.tileType.canSelect
            ? WakColor.grey200 /* <= color if isSelected*/ : Colors.transparent,
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
              SizedBox(width: widget.tileType.padding),
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
                        child: widget.tileType.icon,
                      )
                    : widget.tileType.icon!,
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
    int diff = widget.rank - widget.song.last;
    /* NEW */
    if (widget.song.last == 0) {
      return Text(
        'NEW',
        style: WakText.txt11M.copyWith(color: WakColor.orange),
        textAlign: TextAlign.center,
      );
    }
    /* ZERO */
    else if (diff == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(
            Icons.remove,
            size: 12,
            color: Color(0xFF202F61),
          ),
        ],
      );
    }
    /* UP or DOWN */
    else {
      Color color = diff < 0 ? WakColor.pink : WakColor.blue;
      return Row(
        children: [
          Icon(
            diff < 0
                ? Icons.arrow_drop_up_rounded
                : Icons.arrow_drop_down_rounded,
            size: 12,
            color: color,
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
