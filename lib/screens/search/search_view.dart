import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/common/edit_btn.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/rec_playlist.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';
import 'package:wakmusic/widgets/common/exitable.dart';
import 'package:wakmusic/widgets/show_modal.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final TextEditingController _fieldText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SearchViewModel>(context);
    statusNavColor(context, ScreenType.search);
    final selectedList = Provider.of<SelectSongProvider>(context);
    _fieldText.text = viewModel.text;
    _fieldText.selection =
        TextSelection.collapsed(offset: viewModel.text.length);
    return Exitable(
      scopes: const [
        ExitScope.selectedSong,
        ExitScope.openedPageRouteBuilder,
        ExitScope.searchDuring,
        ExitScope.searchAfter,
      ],
      onExitable: (scope) {
        if (scope == ExitScope.selectedSong && ExitScope.searchAfter.contain) {
          ExitScope.remove = ExitScope.selectedSong;
          selectedList.clearList();
          final navProvider = Provider.of<NavProvider>(context, listen: false);
          final audioProvider =
              Provider.of<AudioProvider>(context, listen: false);
          navProvider.subChange(1);
          if (audioProvider.isEmpty) navProvider.subSwitchForce(false);
          viewModel.updateStatus(SearchStatus.before);
        }
        if (scope == ExitScope.searchDuring) {
          FocusManager.instance.primaryFocus?.unfocus();
          viewModel.updateStatus(ExitScope.searchAfter.contain
              ? SearchStatus.after
              : SearchStatus.before);
          return;
        }
        if (scope == ExitScope.searchAfter) {
          viewModel.updateStatus(SearchStatus.before);
        }
      },
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: () {
              switch (viewModel.curStatus) {
                case SearchStatus.before:
                  return const SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: RecPlaylist(),
                    ),
                  );
                case SearchStatus.during:
                  return _buildDuring(context);
                case SearchStatus.after:
                  return _buildAfter(context);
              }
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    NavProvider navProvider = Provider.of<NavProvider>(context);
    final selectedList = Provider.of<SelectSongProvider>(context);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: 56 + statusBarHeight,
      padding: EdgeInsets.fromLTRB(20, 16 + statusBarHeight, 20, 16),
      color: (viewModel.curStatus == SearchStatus.during)
          ? WakColor.lightBlue
          : Colors.white,
      child: TextFormField(
        controller: _fieldText,
        onTap: () {
          viewModel.updateStatus(SearchStatus.during);
          selectedList.clearList();
        },
        onChanged: (text) {
          if (viewModel.curStatus != SearchStatus.during) {
            viewModel.updateStatus(SearchStatus.during);
            selectedList.clearList();
          }
        },
        onFieldSubmitted: (keyword) {
          if (keyword.isNotEmpty) {
            viewModel.search(keyword);
          } else {
            viewModel.updateText(keyword);
            showModal(
              context: context,
              builder: (_) => const PopUp(
                type: PopUpType.txtOneBtn,
                msg: '검색어를 입력해주세요.',
              ),
            );
            FocusManager.instance.primaryFocus?.requestFocus();
          }
        },
        textInputAction: TextInputAction.search,
        style: WakText.txt16M.copyWith(
          height: 1.0,
          color: (viewModel.curStatus == SearchStatus.during)
              ? Colors.white
              : WakColor.grey900,
        ),
        cursorColor: (viewModel.curStatus == SearchStatus.during)
            ? Colors.white
            : WakColor.grey900,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: '검색어를 입력하세요.',
          hintStyle: WakText.txt16M.copyWith(
            color: (viewModel.curStatus == SearchStatus.before)
                ? WakColor.grey400
                : WakColor.grey25.withOpacity(0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SvgPicture.asset(
              'assets/icons/ic_24_line_search_grey${(viewModel.curStatus == SearchStatus.during) ? '25' : '400'}.svg',
              width: 24,
              height: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(maxWidth: 32),
          suffixIcon: (viewModel.curStatus != SearchStatus.before)
              ? GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    viewModel.updateStatus(SearchStatus.before);
                    selectedList.clearList();
                    navProvider.subChange(1);
                    if (audioProvider.isEmpty) navProvider.subSwitchForce(false);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: EditBtn(type: BtnType.cancel),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(maxWidth: 53),
        ),
      ),
    );
  }

  Widget _buildDuring(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    if (viewModel.history.isEmpty) {
      return const ErrorInfo(errorMsg: '최근 검색 기록이 없습니다.');
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색어',
                  style: WakText.txt16B,
                ),
                GestureDetector(
                  onTap: () {
                    viewModel.updateText(_fieldText.text);
                    showModal(
                      context: context,
                      builder: (context) => PopUp(
                        type: PopUpType.txtTwoBtn,
                        msg: '전체 내역을 삭제하시겠습니까?',
                        posFunc: () => viewModel.clearHistory(),
                      ),
                    );
                  },
                  child: Text(
                    '전체삭제',
                    style: WakText.txt14MH.copyWith(color: WakColor.grey400),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHistory(context),
          ],
        ),
      );
    }
  }

  Widget _buildHistory(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    return Expanded(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: viewModel.history.length,
        itemBuilder: (_, idx) => SizedBox(
          height: 24,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    viewModel.search(viewModel.history[idx]);
                  },
                  child: Text(
                    viewModel.history[idx],
                    style: WakText.txt14MH,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  viewModel.updateText(_fieldText.text);
                  viewModel.removeHistory(idx);
                },
                child: SvgPicture.asset(
                  'assets/icons/ic_24_close.svg',
                  width: 24,
                  height: 24,
                ),
              )
            ],
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      ),
    );
  }

  Widget _buildAfter(BuildContext context) {
    return TabView(
      type: TabType.maxTab,
      tabBarList: List.generate(
          4, (idx) => (idx == 0) ? '전체' : SearchType.values[idx - 1].str),
      tabViewList: List.generate(
        4,
        (idx) => (idx == 0)
            ? _buildTotalTab(context)
            : _buildTab(context, SearchType.values[idx - 1]),
      ),
    );
  }

  Widget _buildTotalTab(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    return FutureBuilder<List<List<Song>>>(
      future: Future.wait(
        [
          viewModel.resultLists[SearchType.title]!,
          viewModel.resultLists[SearchType.artist]!,
          viewModel.resultLists[SearchType.remix]!,
        ],
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<int> tabs = [];
          for (int tabIdx = 0; tabIdx < 3; tabIdx++) {
            if (snapshot.data![tabIdx].isNotEmpty) tabs.add(tabIdx);
          }
          if (tabs.isEmpty) {
            return const ErrorInfo(errorMsg: '검색 결과가 없습니다.');
          /*} else if (tabs.length == 1) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: snapshot.data![tabs[0]].length + 1,
              itemBuilder: (context, songIdx) => (songIdx == 0)
                  ? _buildTabHeader(
                      context, tabs[0], snapshot.data![tabs[0]].length, true)
                  : SongTile(
                      song: snapshot.data![tabs[0]][songIdx - 1],
                      tileType: TileType.dateTile,
                    ),
            );*/
          } else {
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: 3,
              itemBuilder: (context, idx) => Column(
                children: [
                  _buildTabHeader(context, idx,
                      snapshot.data![idx].length, true),
                  tabs.contains(idx)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (songIdx) => (songIdx < snapshot.data![idx].length)
                            ? SongTile(
                                song: snapshot.data![idx][songIdx],
                                tileType: TileType.dateTile,
                              )
                            : Container(),
                      ),
                    )
                  : Container()
                ],
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            );
          }
        } else {
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 3,
            itemBuilder: (context, _) => Column(
              children: [
                _buildTabHeader(context, null, null, false),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (_) => const SongTile(
                      song: null,
                      tileType: TileType.dateTile,
                    ),
                  ),
                ),
              ],
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
          );
        }
      },
    );
  }

  Widget _buildTabHeader(
      BuildContext context, int? tabIdx, int? length, bool hasData) {
    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            SkeletonText(wakTxtStyle: WakText.txt16M, width: 28),
            const SizedBox(width: 4),
            SkeletonText(wakTxtStyle: WakText.txt16M, width: 17),
            const Spacer(),
            SkeletonText(wakTxtStyle: WakText.txt12MH, width: 52),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            Text(
              SearchType.values[tabIdx!].str,
              style: WakText.txt16M,
            ),
            const SizedBox(width: 4),
            Text(
              length.toString(),
              style: WakText.txt16M.copyWith(color: WakColor.lightBlue),
            ),
            const Spacer(),
            (length != null && length > 0)
            ? GestureDetector(
                onTap: () =>
                    DefaultTabController.of(context)!.animateTo(tabIdx + 1),
                child: Row(
                  children: [
                    Text(
                      '전체보기',
                      style: WakText.txt12MH,
                      textAlign: TextAlign.right,
                    ),
                    SvgPicture.asset(
                      'assets/icons/ic_16_arrow_right_search.svg',
                      width: 12,
                      height: 16,
                    ),
                  ],
                ),
              )
            : Container()
          ],
        ),
      );
    }
  }

  Widget _buildTab(BuildContext context, SearchType type) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    return FutureBuilder<List<Song>>(
      future: viewModel.resultLists[type],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const ErrorInfo(errorMsg: '검색 결과가 없습니다.');
        } else {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: (snapshot.hasData) ? snapshot.data!.length : 10,
            itemBuilder: (_, idx) => SongTile(
              song: (snapshot.hasData) ? snapshot.data![idx] : null,
              tileType: TileType.dateTile,
            ),
          );
        }
      },
    );
  }
}
