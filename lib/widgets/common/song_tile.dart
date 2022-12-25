import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class SongTile extends StatefulWidget {
  const SongTile({
    super.key,
    required this.song,
    this.isHome = false,
    this.isCurrent = false,
    this.canPlay = false,
    this.rank = 0,
    this.showDate = false,
  });
  final Song song;
  final bool isHome;
  final bool isCurrent;
  final bool canPlay;
  final int rank; // showViews = rank != 0
  final bool showDate;

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isHome ? 42 : 60,
      child: Row(
        children: [
          if (widget.rank != 0) _buildRank(context),
          if (widget.rank != 0) const SizedBox(width: 8),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: WakText.txt14MH.copyWith(
                    color: widget.isCurrent
                        ? WakColor.lightBlue
                        : WakColor.grey900,
                  ),
                ),
                Text(
                  widget.song.artist,
                  style: WakText.txt12L.copyWith(
                    color: widget.isCurrent
                        ? WakColor.lightBlue
                        : WakColor.grey900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              width: widget.rank != 0
                  ? 12
                  : widget.isCurrent
                      ? 56
                      : widget.showDate
                          ? 39
                          : 60),
          if (widget.canPlay)
            const Icon(
              Icons.play_circle_fill_rounded,
              size: 24,
            ),
          if (widget.isCurrent)
            const Icon(
              Icons.rectangle_rounded,
              size: 40,
            ),
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
          Text(
            diff.toString(),
            style: WakText.txt11M.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
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
}
