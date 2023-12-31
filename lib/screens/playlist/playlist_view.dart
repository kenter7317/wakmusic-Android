import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/dismissible_view.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
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
    NavProvider navProvider = Provider.of<NavProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);

    return DismissibleView(
      onDismissed: () => _canPop(
        context,
        viewModel,
        selectedList,
        dismissible: false,
      ).whenComplete(() {
        ExitScope.remove = ExitScope.editMode;
        ExitScope.remove = ExitScope.openedPageRouteBuilder;
        viewModel.isOpened = false;
        Navigator.pop(
          context,
          playlist.copyWith(
            title: viewModel.title,
            songs: viewModel.songs.whereType<Song>().toList(),
          ),
        );
        viewModel.title = null;
        if (audioProvider.isEmpty) {
          navProvider.subSwitchForce(false);
        } else {
          navProvider.subChange(1);
        }
      }),
      maxTransformValue: 0.1,
      dismissThresholds: const {
        DismissiblePageDismissDirection.startToEnd: 0.1,
      },
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Future<bool> _canPop(
    BuildContext context,
    PlaylistViewModel viewModel,
    SelectSongProvider selectedList, {
    bool dismissible = true,
  }) async {
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
              ) ??
              ((dismissible) ? null : false);
          viewModel.applySongs(result);
        }
        if (result != null) selectedList.clearList();
        return false;
    }
  }

  Widget _buildBody(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
    return Exitable(
      scopes: const [ExitScope.editMode, ExitScope.openedPageRouteBuilder],
      onExitable: (scope) async {
        if (scope == ExitScope.editMode) {
          ExitScope.remove = ExitScope.editMode;
          viewModel.applySongs(!listEquals(
            viewModel.songs,
            viewModel.tempsongs,
          ));
          selectedList.clearList();
          return;
        }
        if (scope == ExitScope.openedPageRouteBuilder) {
          if (await _canPop(context, viewModel, selectedList)) {
            ExitScope.remove = ExitScope.openedPageRouteBuilder;
            viewModel.isOpened = false;
            final nav = Provider.of<NavProvider>(context, listen: false);
            final audio = Provider.of<AudioProvider>(context, listen: false);
            if (nav.subState == true && nav.subIdx == 6) {
              if (audio.isEmpty) {
                nav.subSwitchForce(false);
              } else {
                nav.subChange(1);
              }
            }
            Navigator.pop(
              context,
              playlist.copyWith(
                title: viewModel.title,
                songs: viewModel.songs.whereType<Song>().toList(),
              ),
            );
            viewModel.title = null;
          }
          return;
        }
      },
      child: FutureBuilder<void>(
        future: viewModel.getSongs(playlist),
        builder: (context, _) {
          bool isEmpty = viewModel.songs.isEmpty;
          return StreamBuilder<bool>(
            stream: viewModel.isScrolled.stream,
            builder: (context, snapshot) {
              return SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: CustomScrollView(
                        clipBehavior: (snapshot.data ?? false)
                            ? Clip.hardEdge
                            : Clip.none,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPersistentHeader(
                            delegate: MyHeaderDelegate(
                              widget: _buildInfo(context),
                              extent: 156,
                            ),
                          ),
                          if (isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: ErrorInfo(errorMsg: '리스트에 곡이 없습니다.'),
                            ),
                          if (!isEmpty)
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: MyHeaderDelegate(
                                widget: PlayBtns(
                                  listCallback: () async {
                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'PlaylistAllPlay',
                                      parameters: {'key': playlist.key},
                                    );
                                    return viewModel.tempsongs;
                                  },
                                  isPlaylistView: true,
                                ),
                                extent: 72,
                                isOpacityChange: false,
                              ),
                            ),
                          if (!isEmpty) _buildSonglist(context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    SelectSongProvider selectedList = Provider.of<SelectSongProvider>(context);
    NavProvider navProvider = Provider.of<NavProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 13),
            child: GestureDetector(
              onTap: () async {
                if (audioProvider.isEmpty) {
                  navProvider.subSwitchForce(false);
                } else {
                  navProvider.subChange(1);
                }
                if (await _canPop(context, viewModel, selectedList)) {
                  viewModel.isOpened = false;
                  Navigator.pop(
                    context,
                    playlist.copyWith(
                      title: viewModel.title,
                      songs: viewModel.songs.whereType<Song>().toList(),
                    ),
                  );
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
                      if (navProvider.subState == true &&
                          navProvider.subIdx == 6) {
                        if (audioProvider.isEmpty) {
                          navProvider.subSwitchForce(false);
                        } else {
                          navProvider.subChange(1);
                        }
                      } else {
                        navProvider.subChange(6);
                        navProvider.subSwitchForce(true);
                      }
                      // if (viewModel.curStatus == EditStatus.editing) {
                      //   /* editing <= for test */
                      //   viewModel.updateStatus(EditStatus.none);
                      // } else {
                      //   viewModel.updateStatus(EditStatus.editing);
                      // }
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
                          style: WakText.txt16M,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            ExitScope.remove = ExitScope.editMode;
                            viewModel.applySongs(!listEquals(
                              viewModel.songs,
                              viewModel.tempsongs,
                            ));
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          ExtendedImage.network(
            '${API.static.url}/playlist/'
            '${(playlist is Reclist) ? 'icon/square/${playlist.key}' : playlist.image.name}.png'
            '?v=${(playlist is Reclist) ? playlist.image.square : playlist.image.version}',
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
            cacheMaxAge: const Duration(days: 30),
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
                    viewModel.title ?? playlist.title,
                    style: WakText.txt20B,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      (viewModel.songs.isNotEmpty &&
                              viewModel.songs.first == null)
                          ? SkeletonText(
                              wakTxtStyle: WakText.txt14L,
                              width: 26,
                            )
                          : Text(
                              '${viewModel.songs.length}곡',
                              style: WakText.txt14L.copyWith(
                                color: WakColor.grey900.withOpacity(0.6),
                              ),
                            ),
                      if (viewModel.curStatus == EditStatus.editing)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: GestureDetector(
                            onTap: () async {
                              viewModel.updateTitle(
                                await showModal(
                                  context: context,
                                  builder: (_) => BotSheet(
                                    type: BotSheetType.editList,
                                    initialValue: playlist.title,
                                  ),
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

    return (viewModel.curStatus != EditStatus.editing)
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, idx) => SongTile(
                song: viewModel.songs[idx],
                tileType: (playlist is! Reclist)
                    ? TileType.canPlayTile
                    : TileType.dateTile,
                onLongPress: (playlist is! Reclist)
                    ? () => viewModel.updateStatus(EditStatus.editing)
                    : null,
              ),
              childCount: viewModel.songs.length,
            ),
          )
        : SliverReorderableList(
            proxyDecorator: proxyDecorator,
            itemCount: viewModel.tempsongs.length,
            itemBuilder: (_, idx) => SongTile(
              key: Key(idx.toString()),
              song: viewModel.tempsongs[idx],
              idx: idx,
              tileType: TileType.editTile,
            ),
            onReorder: (oldIdx, newIdx) {
              viewModel.moveSong(
                  oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
            },
            onReorderStart: (_) => HapticFeedback.lightImpact(),
          );
  }
}

class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  MyHeaderDelegate(
      {required this.widget,
      required this.extent,
      this.isOpacityChange = true});

  Widget widget;
  double extent;
  bool isOpacityChange;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    PlaylistViewModel viewModel = Provider.of<PlaylistViewModel>(context);
    double progress = shrinkOffset / maxExtent;
    if (isOpacityChange) viewModel.updateScroll((progress >= 1.0));
    return (isOpacityChange)
        ? AnimatedOpacity(
            duration: Duration.zero,
            opacity: 1 - progress,
            child: widget,
          )
        : widget;
  }

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
