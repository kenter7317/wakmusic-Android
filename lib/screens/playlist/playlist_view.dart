import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:wakmusic/widgets/proxy_decorator.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
    return DismissibleView(
      onDismissed: () {
        _canPop(context, viewModel, selectedList, dismissible: false).whenComplete(() => Navigator.pop(context));
      },
      maxTransformValue: 0.1,
      dismissThresholds: const { DismissiblePageDismissDirection.startToEnd: 0.1 },
      child: Scaffold(body: _buildBody(context)),
    );
  }

  Future<bool> _canPop(BuildContext context, PlaylistViewModel viewModel, SelectSongProvider selectedList, {bool dismissible = true}) async {
    switch (viewModel.curStatus) {
      case EditStatus.none:
        selectedList.clearList();
        return true;
      case EditStatus.more:
        viewModel.updateStatus(EditStatus.none);
        return false;
      case EditStatus.editing:
        bool? result;
        if (listEquals(viewModel.songs, viewModel.tempsongs)) {
          viewModel.updateStatus(EditStatus.none);
          result = true;
        } else {
          result = await showModal(
            context: context,
            builder: (_) => const PopUp(
              type: PopUpType.txtTwoBtn,
              msg: '변경된 내용을 저장할까요?',
            ),
          ) ?? ((dismissible) ? null : false);
          viewModel.applySongs(result);
        }
        if (result != null) selectedList.clearList();
        return false;
    }
  }

  Widget _buildBody(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
    return WillPopScope(
      onWillPop: () => _canPop(context, viewModel, selectedList),
      child: FutureBuilder<void>(
        future: viewModel.getSongs(playlist.songlist.join(',')),
        builder: (context, _) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildInfo(context),
                Expanded(
                  child: (playlist.songlist.where((songId) => songId.isNotEmpty).isEmpty)
                    ? const ErrorInfo(errorMsg: '플레이리스트에 곡이 없습니다.')
                    : Column(
                        children: [
                          const PlayBtns(),
                          _buildSonglist(context),
                        ],
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: GestureDetector(
              onTap: () async {
                if (await _canPop(context, viewModel, selectedList)) {
                  Navigator.pop(context);
                }
              },
              child: SvgPicture.asset(
                'assets/icons/ic_32_arrow_left.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
          if (playlist is! Reclist)
            (viewModel.curStatus != EditStatus.editing)
              ? GestureDetector(
                  onTap: () {
                    if (viewModel.curStatus == EditStatus.editing) { /* editing <= for test */
                      viewModel.updateStatus(EditStatus.none);
                    } else {
                      viewModel.updateStatus(EditStatus.editing);
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/ic_32_more.svg',
                    width: 32,
                    height: 32,
                  ),
                )
              : Expanded(
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        '편집',
                        style: WakText.txt16M.copyWith(color: WakColor.grey900),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          viewModel.applySongs(true);
                          selectedList.clearList();
                        },
                        child: const EditBtn(type: BtnType.done),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          ExtendedImage.network(
            '$staticBaseUrl/playlist/${(playlist is! Reclist) ? playlist.image : 'icon/square/${playlist.image}'}.png',
            fit: BoxFit.cover,
            shape: BoxShape.rectangle,
            width: 140,
            height: 140,
            borderRadius: BorderRadius.circular(12),
            loadStateChanged: (state) {
              if (state.extendedImageLoadState != LoadState.completed) {
                return SkeletonBox(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: WakColor.grey200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } 
              return null;
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                border: Border.all(color: WakColor.grey25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: WakText.txt20B.copyWith(color: WakColor.grey900),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${playlist.songlist.where((songId) => songId.isNotEmpty).length}곡',
                        style: WakText.txt14L.copyWith(color: WakColor.grey900.withOpacity(0.6)),
                      ),
                      if (viewModel.curStatus == EditStatus.editing)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: GestureDetector(
                            onTap: () {
                              showModal(
                                context: context,
                                builder: (_) => BotSheet(
                                  type: BotSheetType.editList,
                                  initialValue: playlist.title,
                                ),
                              );
                            },
                            child: SvgPicture.asset(
                              'assets/icons/ic_24_edit.svg',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSonglist(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    return Expanded(
      child: (viewModel.curStatus != EditStatus.editing) 
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: viewModel.songs.length,
            itemBuilder: (_, idx) => SongTile(
              song: viewModel.songs[idx],
              tileType: (playlist is! Reclist) ? TileType.canPlayTile : TileType.dateTile,
              onLongPress: (playlist is! Reclist)
                ? () => viewModel.updateStatus(EditStatus.editing)                  
                : null,
            ),
          )
        : ReorderableListView.builder(
            proxyDecorator: proxyDecorator,
            buildDefaultDragHandles: false,
            physics: const BouncingScrollPhysics(),
            itemCount: viewModel.tempsongs.length,
            itemBuilder: (_, idx) => SongTile(
              key: Key(idx.toString()),
              song: viewModel.tempsongs[idx],
              idx: idx,
              tileType: TileType.editTile,
            ),
            onReorder: (oldIdx, newIdx) {
              viewModel.moveSong(oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
            },
            onReorderStart: (_) => HapticFeedback.lightImpact(),
          ),
    );
  }
}