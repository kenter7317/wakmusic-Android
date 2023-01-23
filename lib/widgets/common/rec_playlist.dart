import 'package:flutter/material.dart';
import 'package:wakmusic/screens/playlist/playlist_view.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:provider/provider.dart';

class RecPlaylist extends StatelessWidget {
  const RecPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    RecPlaylistProvider recPlaylist = Provider.of<RecPlaylistProvider>(context);
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: () {
          List<Widget> children = [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                '왁뮤팀이 추천하는 플레이리스트',
                style: WakText.txt16B.copyWith(color: WakColor.grey900),
              ),
            ),
          ];
          children.addAll(
            List.generate(
              3,
              (idx) => Row(
                children: [
                  _buildPlaylist(context, recPlaylist.list[idx * 2]),
                  const SizedBox(width: 8),
                  _buildPlaylist(context, recPlaylist.list[idx * 2 + 1]),
                ],
              ),
            ),
          );
          return children;
        }(),
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context, Reclist? playlist) {
    if (playlist == null) {
      return Expanded(
        child: SkeletonBox(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: WakColor.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => PlaylistView(playlist: playlist, canEdit: false),
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                opaque: false,
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                }
              ),
            );
          },
          child: Container(
            height: 80,
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
            decoration: BoxDecoration(
              color: WakColor.grey25,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    playlist.title,
                    style: WakText.txt14MH.copyWith(color: WakColor.grey600),
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  'assets/icons/ic_48_${playlist.iconName}.png',
                  width: 48,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
