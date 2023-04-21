import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/suggestions.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/btn_with_icon.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';
import 'package:wakmusic/widgets/keep/bot_sheet.dart';
import 'package:wakmusic/widgets/keep/playlist_tile.dart';
import 'package:wakmusic/widgets/keep/policy.dart';
import 'package:wakmusic/widgets/keep/keep_tab_view.dart';
import 'package:wakmusic/widgets/page_route_builder.dart';
import 'package:wakmusic/widgets/proxy_decorator.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class KeepView extends StatelessWidget {
  const KeepView({super.key});

  @override
  Widget build(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: () {
          switch (viewModel.loginStatus) {
            case LoginStatus.before:
              return _buildBefore(context);
            case LoginStatus.after:
              return _buildAfter(context);
          }
        }(),
      ),
    );
  }

  Widget _buildBefore(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double botPadding = WidgetsBinding.instance.window.viewPadding.bottom / WidgetsBinding.instance.window.devicePixelRatio;
    double height = MediaQuery.of(context).size.height - statusBarHeight - botPadding;
    double blankFactor;
    if (height >= 672) {
      blankFactor = (732 - height) / 3;
    } else {
      blankFactor = 20;
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: 52 - blankFactor),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(92 * 13 / 60),
            child: Image.asset(
              'assets/icons/appicon.png',
              width: 92,
              height: 92,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '왁타버스 뮤직',
          style: WakText.txt20M.copyWith(color: WakColor.grey900),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '페이지를 이용하기 위해 로그인이 필요합니다.',
          style: WakText.txt14L.copyWith(color: WakColor.grey600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40 - blankFactor),
        SizedBox(
          height: 196,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Login.values.length,
            itemBuilder: (_, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BtnWithIcon(
                onTap: () {
                  viewModel.getUser();
                  viewModel.updateLoginStatus(LoginStatus.after);
                },
                type: BtnSizeType.big,
                iconName: Login.values[idx].name,
                btnText: '${Login.values[idx].locale}로 로그인하기',
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
          ),
        ),
        SizedBox(height: 40 - blankFactor),
        const Policy(),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<bool> _canTap(
    BuildContext context, 
    KeepViewModel viewModel, 
    SelectPlaylistProvider selectedPlaylist, 
    SelectSongProvider selectedLike,
  ) async {
    bool? result;
    switch (viewModel.editStatus) {
      case EditStatus.none:
        return true;
      case EditStatus.playlists:
        if (!listEquals(viewModel.playlists, viewModel.tempPlaylists)) {
          result = await showModal(
            context: context,
            builder: (_) => const PopUp(
              type: PopUpType.txtTwoBtn,
              msg: '변경된 내용을 저장할까요?',
            ),
          );
          viewModel.applyPlaylists(result);
        } else {
          viewModel.updateEditStatus(EditStatus.none);
          result = true;
        }
        if (result != null) {
          selectedPlaylist.clearList();
          return true;
        }
        return false;
      case EditStatus.likes:
        if (!listEquals(viewModel.likes, viewModel.tempLikes)) {
          result = await showModal(
            context: context,
            builder: (_) => const PopUp(
              type: PopUpType.txtTwoBtn,
              msg: '변경된 내용을 저장할까요?',
            ),
          );
          viewModel.applyLikes(result);
        } else {
          viewModel.updateEditStatus(EditStatus.none);
          result = true;
        }
        if (result != null) {
          selectedLike.clearList();
          return true;
        }
        return false;
    }
  }

  GestureDetector tabDetector(
    BuildContext context, {
    required void Function() onTap,  
    HitTestBehavior? behavior, 
    required Widget child,
  }) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    SelectPlaylistProvider selectedPlaylist = Provider.of<SelectPlaylistProvider>(context);
    SelectSongProvider selectedLike = Provider.of<SelectSongProvider>(context);
    return GestureDetector(
      onTap: () async {
        if(await _canTap(context, viewModel, selectedPlaylist, selectedLike)) onTap();
      },
      behavior: behavior,
      child: child,
    );
  }

  Widget _buildAfter(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    SelectPlaylistProvider selectedPlaylist = Provider.of<SelectPlaylistProvider>(context);
    SelectSongProvider selectedLike = Provider.of<SelectSongProvider>(context);
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Stack(
            children: [
              NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: KeepTabView(
                  type: TabType.minTab,
                  tabBarList: const ['내 리스트', '좋아요'],
                  tabViewList: [_buildPlaylistTab(context), _buildLikeTab(context)],
                  onPause: (viewModel.editStatus != EditStatus.none)
                    ? () => _canTap(context, viewModel, selectedPlaylist, selectedLike)
                    : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          tabDetector(
            context,
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              /*viewModel.updateUserProfile(await showModal(
                context: context,
                builder: (_) => BotSheet(
                  type: BotSheetType.selProfile,
                  initialValue: viewModel.user.profile,
                ),
              ));*/
              viewModel.updateUserName(await showModal(
                context: context,
                builder: (_) => BotSheet(
                  type: BotSheetType.editName,
                  initialValue: viewModel.user.displayName,
                ),
              ));
            },
            child: Row(
              children: [
                ExtendedImage.network(
                  '$staticBaseUrl/profile/${viewModel.user.profile}.png',
                  fit: BoxFit.cover,
                  shape: BoxShape.circle,
                  width: 40,
                  height: 40,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState != LoadState.completed) {
                      return SkeletonBox(
                        child: Container(
                          width: 40,
                          height: 40,
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
                const SizedBox(width: 8),
                Text(
                  _nameProcessing(viewModel.user.displayName),
                  style: WakText.txt16M.copyWith(color: WakColor.grey900),
                ),
              ],
            ),            
          ),
          const SizedBox(width: 2),
          tabDetector(
            context,
            onTap: () => viewModel.updateLoginStatus(LoginStatus.before),
            child: SvgPicture.asset(
              'assets/icons/ic_32_logout.svg',
              width: 32,
              height: 32,
            ),
          ),
          const Spacer(),
          tabDetector(
            context,
            onTap: () {
              Navigator.push(
                context,
                pageRouteBuilder(page: const Suggestions()),
              );
            },
            child: SvgPicture.asset(
              'assets/icons/ic_32_request.svg',
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  String _nameProcessing(String rawName) {
    Runes runes = rawName.runes;
    if (runes.length <= 8) return rawName;
    List<String> charList = runes.map((code) => String.fromCharCode(code)).toList();
    String subString = charList.sublist(0, 8).join();
    return '$subString...';
  }

  Widget _buildPlaylistTab(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return Column(
      children: [
        if (viewModel.editStatus != EditStatus.playlists)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SizedBox(
              height: 108,
              child: Column(
                children: [
                  BtnWithIcon(
                    onTap: () async {
                      viewModel.createList(await showModal(
                        context: context, 
                        builder: (_) => const BotSheet(
                          type: BotSheetType.createList,
                        ),
                      ));
                    }, 
                    type: BtnSizeType.small, 
                    iconName: 'playadd_900',
                    btnText: '플레이리스트 만들기',
                  ),
                  const SizedBox(height: 4),
                  BtnWithIcon(
                    onTap: () async { 
                      viewModel.loadList(await showModal(
                        context: context,
                        builder: (_) => const BotSheet(
                          type: BotSheetType.loadList,
                        ),
                      ));
                    }, 
                    type: BtnSizeType.small, 
                    iconName: 'share',
                    btnText: '플레이리스트 가져오기',
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: (viewModel.playlists.isEmpty)
            ? const ErrorInfo(errorMsg: '내 리스트가 없습니다.')
            : (viewModel.editStatus == EditStatus.playlists)
              ? ReorderableListView.builder(
                  key: const PageStorageKey(0),
                  proxyDecorator: proxyDecorator,
                  buildDefaultDragHandles: false,
                  itemCount: viewModel.tempPlaylists.length,
                  itemBuilder: (_, idx) => PlaylistTile(
                    key: Key(idx.toString()),
                    playlist: viewModel.tempPlaylists[idx],
                    idx: idx,
                    tileType: TileType.editTile,
                  ),
                  onReorder: (oldIdx, newIdx) {
                    viewModel.movePlaylist(oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
                  },
                  onReorderStart: (_) => HapticFeedback.lightImpact(),
                )
              : ListView.builder(
                  key: const PageStorageKey(0),
                  itemCount: viewModel.playlists.length,
                  itemBuilder: (_, idx) => PlaylistTile(
                    playlist: viewModel.playlists[idx],
                    tileType: TileType.canPlayTile,
                    onLongPress: () => viewModel.updateEditStatus(EditStatus.playlists),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLikeTab(BuildContext context) {
    KeepViewModel viewModel = Provider.of<KeepViewModel>(context);
    return (viewModel.likes.isEmpty)
      ? const ErrorInfo(errorMsg: '좋아요 한 곡이 없습니다.')
      : (viewModel.editStatus == EditStatus.likes)
        ? ReorderableListView.builder(
            key: const PageStorageKey(1),
            proxyDecorator: proxyDecorator,
            buildDefaultDragHandles: false,
            itemCount: viewModel.tempLikes.length,
            itemBuilder: (_, idx) => SongTile(
              key: Key(idx.toString()),
              song: viewModel.tempLikes[idx],
              idx: idx,
              tileType: TileType.editTile,
            ),
            onReorder: (oldIdx, newIdx) {
              viewModel.moveSong(oldIdx, (oldIdx < newIdx) ? newIdx - 1 : newIdx);
            },
            onReorderStart: (_) => HapticFeedback.lightImpact(),
          )
        : ListView.builder(
            key: const PageStorageKey(1),
            itemCount: viewModel.likes.length,
            itemBuilder: (_, idx) => SongTile(
              song: viewModel.likes[idx], 
              tileType: TileType.canPlayTile,
              onLongPress: () => viewModel.updateEditStatus(EditStatus.likes),
            ),
          );
  }
}