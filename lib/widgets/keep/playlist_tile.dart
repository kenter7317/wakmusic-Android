import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/playlist/playlist_view.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.tileType,
    this.idx = 0,
    this.onLongPress,
  });
  final Playlist? playlist;
  final TileType tileType;
  final int idx;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (playlist == null) {
      return _buildSkeleton(context);
    } else {
      final selectedList = Provider.of<SelectPlaylistProvider>(context);
      bool isSelected = selectedList.list.contains(playlist);
      SelectSongProvider selSongProvider = Provider.of<SelectSongProvider>(context);
      NavProvider navProvider = Provider.of<NavProvider>(context);
      AudioProvider audioProvider = Provider.of<AudioProvider>(context);
      
      return GestureDetector(
        onTap: () async {
          if (tileType.canSelect) {
            if (isSelected) {
              selectedList.removePlaylist(playlist!);
            } else {
              selectedList.addPlaylist(playlist!);
            }
          } else if (tileType == TileType.baseTile) {
            final selectedSongs =
                Provider.of<SelectSongProvider>(context, listen: false);
            final viewModel =
                Provider.of<KeepViewModel>(context, listen: false);

            viewModel.addSongs(playlist!, selectedSongs.list).then((value) {
              if (value != -1) {
                showToastWidget(
                  context: context,
                  position: const StyledToastPosition(
                    align: Alignment.bottomCenter,
                    offset: 56,
                  ),
                  animation: StyledToastAnimation.slideFromBottomFade,
                  reverseAnimation: StyledToastAnimation.fade,
                  ToastMsg(msg: '$value곡을 리스트에 담았습니다.'),
                );
                selSongProvider.clearList();
                if (audioProvider.isEmpty) {
                  navProvider.subSwitchForce(false);
                } else {
                  navProvider.subChange(1);
                }
              }
              Navigator.pop(context);
            });
          } else {
            final viewModel =
                Provider.of<KeepViewModel>(context, listen: false);
            Navigator.push(
              context,
              pageRouteBuilder(page: PlaylistView(playlist: playlist!)),
            ).then((changed) => viewModel.updatePlaylist(playlist!, changed));
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
            height: 60,
            child: Row(
              children: [
                ExtendedImage.network(
                  '$staticBaseUrl/playlist/${playlist!.image}.png'
                  '?v=${playlist!.imageVersion}',
                  fit: BoxFit.cover,
                  shape: BoxShape.rectangle,
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(4),
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState != LoadState.completed) {
                      return SkeletonBox(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: WakColor.grey200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  cacheMaxAge: const Duration(days: 30),
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
                          playlist!.title,
                          style: WakText.txt14MH,
                        ),
                      ),
                      SizedBox(
                        height: 18,
                        child: Text(
                          '${playlist!.songlist!.where((songId) => songId.isNotEmpty).length}곡',
                          style: WakText.txt12L,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tileType.padding['middle']),
                if (tileType == TileType.canPlayTile)
                  GestureDetector(
                    onTap: () {
                      /* play playlist */
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

  Widget _buildSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          tileType.padding['start']!, 0, tileType.padding['end']!, 0),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            SkeletonBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WakColor.grey200,
                    borderRadius: BorderRadius.circular(4),
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
