import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/screens/playlist/playlist_view.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models_v2/playlist/reclist.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';

class RecPlaylist extends StatelessWidget {
  const RecPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    RecPlaylistProvider recPlaylist = Provider.of<RecPlaylistProvider>(context);
    return FutureBuilder<List<Reclist>>(
      future: recPlaylist.list,
      builder: (context, snapshot) {
        int length = (snapshot.data?.length ?? 6), rowN = (length / 2).round();
        double height = rowN * 88 - 8;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '왁뮤팀이 추천하는 리스트',
              style: WakText.txt16B.copyWith(color: WakColor.grey900),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: height,
              child: GridView.builder(
                itemCount: length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 80,
                ),
                padding: EdgeInsets.zero,
                itemBuilder: (context, idx) {
                  return _buildPlaylist(context, snapshot.data?[idx]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylist(BuildContext context, Reclist? playlist) {
    if (playlist == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
        decoration: BoxDecoration(
          color: WakColor.grey25,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: SkeletonText(wakTxtStyle: WakText.txt14MH),
            ),
            const SizedBox(width: 14),
            SkeletonBox(
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: WakColor.grey200,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          final vm = Provider.of<PlaylistViewModel>(context, listen: false);
          if (vm.isOpened) {
            showToastWidget(
              context: context,
              position: const StyledToastPosition(
                align: Alignment.bottomCenter,
                offset: 56,
              ),
              animation: StyledToastAnimation.slideFromBottomFade,
              reverseAnimation: StyledToastAnimation.fade,
              const ToastMsg(msg: '다른 리스트가 열려있습니다. 리스트를 닫고 다시 시도해주세요.'),
            );
          } else {
            vm.isOpened = true;
            Navigator.push(
              context,
              pageRouteBuilder(page: PlaylistView(playlist: playlist)),
            );
          }
        },
        child: Container(
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
                  style: WakText.txt14M.copyWith(color: WakColor.grey600),
                  maxLines: 4,
                ),
              ),
              const SizedBox(width: 14),
              ExtendedImage.network(
                '${API.static.url}/playlist/icon/round/'
                '${playlist.key}.png'
                '?v=${playlist.image.round}',
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
      );
    }
  }
}
