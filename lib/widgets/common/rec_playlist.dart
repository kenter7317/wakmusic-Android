import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/screens/playlist/playlist_view.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class RecPlaylist extends StatelessWidget {
  const RecPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    RecPlaylistProvider recPlaylist = Provider.of<RecPlaylistProvider>(context);
    return SizedBox(
      // height: 300,
      child: FutureBuilder<void>(
        future: recPlaylist.getLists(),
        builder: (context, _) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: () {
            List<Widget> children = [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '왁뮤팀이 추천하는 리스트',
                  style: WakText.txt16B,
                ),
              ),
            ];
            children.addAll(
              List.generate(
                (recPlaylist.list.length / 2).round(),
                (idx) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      if (recPlaylist.list.isNotEmpty) ...[
                        _buildPlaylist(context, recPlaylist.list[idx * 2]),
                        const SizedBox(width: 8),
                        if (recPlaylist.isOdd) const Spacer(),
                        if (recPlaylist.isEven)
                          _buildPlaylist(
                              context, recPlaylist.list[idx * 2 + 1]),
                      ],
                    ],
                  ),
                ),
              ),
            );
            return children;
          }(),
        ),
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
              pageRouteBuilder(page: PlaylistView(playlist: playlist)),
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
                ExtendedImage.network(
                  '$staticBaseUrl/playlist/icon/round/${playlist.id}.png'
                  '?v=${playlist.imageVersion}',
                  fit: BoxFit.cover,
                  shape: BoxShape.circle,
                  width: 48,
                  height: 48,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState != LoadState.completed) {
                      return SkeletonBox(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: WakColor.grey200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  cacheMaxAge: const Duration(days: 30),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
