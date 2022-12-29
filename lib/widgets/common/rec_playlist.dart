import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class RecPlaylist extends StatelessWidget {
  const RecPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              '왁뮤팀이 추천하는 플레이리스트',
              style: WakText.txt16B.copyWith(color: WakColor.grey900),
            ),
          ),
          Row(
            children: [
              _buildPlaylist(context, '고멤가요제', 'ic_48_GomemSongFestival'),
              const SizedBox(width: 8),
              _buildPlaylist(context, '연말공모전', 'ic_48_Competition'),
            ],
          ),
          Row(
            children: [
              _buildPlaylist(context, '상콘 OST', 'ic_48_situationalplay_OST'),
              const SizedBox(width: 8),
              _buildPlaylist(context, '힙합 SWAG', 'ic_48_Hiphop'),
            ],
          ),
          Row(
            children: [
              _buildPlaylist(context, '캐롤', 'ic_48_carol'),
              const SizedBox(width: 8),
              _buildPlaylist(context, '노동요', 'ic_48_worksong'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context, String name, String icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          /* go to playlist page */
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: WakColor.grey25,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: WakText.txt14MH.copyWith(color: WakColor.grey600),
                ),
              ),
              Image.asset(
                'assets/icons/$icon.png',
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 16)
            ],
          ),
        ),
      ),
    );
  }
}
