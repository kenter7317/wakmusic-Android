import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/screens/player/player_playlist_view_model.dart';
import 'package:wakmusic/style/colors.dart';

import '../../models/providers/nav_provider.dart';
import '../../models/song.dart';
import '../../style/text_styles.dart';
import '../../widgets/common/edit_btn.dart';
import '../../widgets/common/song_tile.dart';

class PlayerPlayList extends StatelessWidget {
  const PlayerPlayList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WakColor.grey100,
      body: _buildBody(context),
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
    PlayerPlayListViewModel viewModel = Provider.of<PlayerPlayListViewModel>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    NavProvider botNav = Provider.of<NavProvider>(context);
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
                style: WakText.txt16M.copyWith(color: WakColor.grey900),
                textAlign: TextAlign.center,
              )),
          (viewModel.state == PageState.edit) ?
            GestureDetector(
              onTap: () {
                viewModel.updateStatus(PageState.normal);
              },
              child: const EditBtn(type: BtnType.done),
            )
          :
            GestureDetector(
              onTap: () {
                viewModel.updateStatus(PageState.edit);
              },
              child: const EditBtn(type: BtnType.edit),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayList(BuildContext context){
    PlayerPlayListViewModel viewModel = Provider.of<PlayerPlayListViewModel>(context);
    return Expanded(
      child: (viewModel.state != PageState.edit)
          ? Selector<AudioProvider, List<Song>>(
              selector: (context, audioProvider) => audioProvider.queue,
              builder: (context, queue, _){
                return Selector<AudioProvider, int>(
                  selector: (context, audioProvider) => audioProvider.currentIndex ?? 0,
                  builder: (context, curIdx, _){
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: queue.length,
                      itemBuilder: (_, idx) => SongTile(
                        song: queue[idx],
                        tileType: idx == curIdx ? TileType.nowPlayTile : TileType.canPlayTile,
                        //onLongPress: () => viewModel.updateStatus(PageState.edit)
                      ),
                    );
                  },
                );
              },
          )
          : Selector<AudioProvider, List<Song>>(
              selector: (context, audioProvider) => audioProvider.queue,
              builder: (context, playList, _){
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
                  itemCount: playList.length,
                  itemBuilder: (_, idx) => SongTile(
                    key: Key(idx.toString()),
                    song: playList[idx],
                    idx: idx,
                    tileType: TileType.editTile,
                  ),
                  onReorder: (oldIdx, newIdx) {
                    Provider.of<AudioProvider>(context, listen: false).swapQueueItem(oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
                  },
                  //onReorderStart: (_) => HapticFeedback.lightImpact(),
                );
              },
          )
    );
  }
}
