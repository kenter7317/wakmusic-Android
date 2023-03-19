import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/main.dart';
import 'package:wakmusic/screens/player/player_playlist_view_model.dart';
import 'package:wakmusic/screens/player/player_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/widgets/player/player_button.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import '../../models/song.dart';
import '../../style/text_styles.dart';
import '../../widgets/common/edit_btn.dart';
import '../../widgets/common/song_tile.dart';
import '../playlist/playlist_view_model.dart';

class PlayerPlayList extends StatelessWidget {
  const PlayerPlayList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WakColor.grey100,
      body: _buildBody(context),
      bottomNavigationBar: _buildPlayerPlayListBottomNav(context),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () => { Navigator.pop(context) },
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
    return FutureBuilder(
      future: viewModel.playList,
      builder: (context, snapshot) {
        return Expanded(
          child: (viewModel.state != PageState.edit)
              ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data?.length,
            itemBuilder: (_, idx) => SongTile(
              song: snapshot.data![idx],
              tileType: TileType.nowPlayTile,
              onLongPress: () => viewModel.updateStatus(PageState.edit)
            ),
          )
              : ReorderableListView.builder(
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
            itemCount: snapshot.data!.length,
            itemBuilder: (_, idx) => SongTile(
              key: Key(idx.toString()),
              song: snapshot.data![idx],
              idx: idx,
              tileType: TileType.editTile,
            ),
            onReorder: (oldIdx, newIdx) {
              //viewModel.moveSong(oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
              print("$oldIdx : $newIdx");
            },
            //onReorderStart: (_) => HapticFeedback.lightImpact(),
          ),
        );
      }
    );
  }

  Widget _buildPlayerPlayListBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(
            color: WakColor.grey100,
          ))
      ),
      height: 56,
    );
  }
}
