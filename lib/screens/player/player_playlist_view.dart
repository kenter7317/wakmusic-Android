import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/player/player_playlist_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/player/player_bottom.dart';

import '../../models/providers/nav_provider.dart';
import '../../models_v2/song.dart';
import '../../style/text_styles.dart';
import '../../widgets/common/edit_btn.dart';
import '../../widgets/common/song_tile.dart';

class PlayerPlayList extends StatelessWidget {
  const PlayerPlayList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Exitable(
      scopes: const [ExitScope.playerPlaylist],
      onExitable: (scope) {
        // if (scope == ExitScope.playerPlaylist) {
        //   final botNav = Provider.of<NavProvider>(context, listen: false);
        //   botNav.subChange(0);
        //   ExitScope.remove = ExitScope.playerPlaylist;
        //   Navigator.pop(context);
        // }
      },
      child: WillPopScope(
        onWillPop: () async {
          final botNav = Provider.of<NavProvider>(context, listen: false);
          botNav.subChange(0);
          FirebaseAnalytics.instance
              .setCurrentScreen(screenName: AppScreen.name(botNav.curIdx));
          return true;
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: WakColor.grey100,
            body: _buildBody(context),
            bottomNavigationBar: getPlayerPlaylistBottom(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        _buildTitleRow(context),
        _buildPlayList(context),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final viewModel = Provider.of<PlayerPlayListViewModel>(context);
    final botNav = Provider.of<NavProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                botNav.subChange(0);
                // ExitScope.remove = ExitScope.playerPlaylist;
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                'assets/icons/ic_32_arrow_bottom.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '재생목록',
              style: WakText.txt16M,
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () => viewModel.updateStatus(
              (viewModel.state == PageState.edit)
                  ? PageState.normal
                  : PageState.edit,
            ),
            child: EditBtn(
              type: (viewModel.state == PageState.edit)
                  ? BtnType.done
                  : BtnType.edit,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayList(BuildContext context) {
    final viewModel = Provider.of<PlayerPlayListViewModel>(context);
    final selProvider = Provider.of<SelectSongProvider>(context);
    return Expanded(
      child: Selector<AudioProvider, List<Song>>(
        selector: (context, audioProvider) => audioProvider.queue,
        builder: (context, queue, _) {
          if (viewModel.state != PageState.edit) {
            return Selector<AudioProvider, int>(
              selector: (context, audioProvider) =>
                  audioProvider.currentIndex ?? 0,
              builder: (context, curIdx, _) {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: queue.length,
                  itemBuilder: (_, idx) => SongTile(
                    song: queue[idx],
                    tileType: idx == curIdx
                        ? TileType.nowPlayTile
                        : TileType.canPlayTile,
                    //onLongPress: () => viewModel.updateStatus(PageState.edit)
                  ),
                );
              },
            );
          } else {
            return ReorderableListView.builder(
              proxyDecorator: (child, _, animation) => AnimatedBuilder(
                animation: animation,
                builder: (_, child) => Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: WakColor.dark.withOpacity(0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
                child: child,
              ),
              buildDefaultDragHandles: false,
              physics: const BouncingScrollPhysics(),
              itemCount: queue.length,
              itemBuilder: (_, idx) => SongTile(
                key: Key(idx.toString()),
                song: queue[idx],
                idx: idx,
                tileType: TileType.playerEditTile,
              ),
              onReorder: (oldIdx, newIdx) {
                Provider.of<AudioProvider>(
                  context,
                  listen: false,
                ).swapQueueItem(
                  oldIdx,
                  (oldIdx < newIdx) ? newIdx - 1 : newIdx,
                );
              },
              //onReorderStart: (_) => HapticFeedback.lightImpact(),
            );
          }
        },
      ),
    );
  }
}
