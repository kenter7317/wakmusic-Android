import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/rec_playlist.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final TextEditingController _fieldText = TextEditingController();
  TabController? _tabCtrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WakColor.grey100,
      body: _buildBody(context),
      bottomNavigationBar: Container(
        height: 56,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: (viewModel.curStatus == SearchStatus.during)
        ? Brightness.light
        : Brightness.dark,
    ));
    return WillPopScope(
      onWillPop: () async {
        if (viewModel.curStatus != SearchStatus.before) {
          FocusManager.instance.primaryFocus?.unfocus();
          _fieldText.clear();
          viewModel.updateStatus(SearchStatus.before);
          return false;
        }
        return true;
      },
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: () {
                switch (viewModel.curStatus) {
                  case SearchStatus.before:
                    return const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: 56 + statusBarHeight,
      padding: EdgeInsets.fromLTRB(20, 16 + statusBarHeight, 20, 16),
      color: (viewModel.curStatus == SearchStatus.during)
        ? WakColor.lightBlue
        : Colors.white,
      child: TextFormField(
        controller: _fieldText,
        onTap: () => viewModel.updateStatus(SearchStatus.during),
        onFieldSubmitted: (keyword) {
          if (keyword.isNotEmpty) {
            viewModel.search(keyword);
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
            : WakColor.grey900),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: '검색어를 입력하세요.',
          hintStyle: WakText.txt16M.copyWith(
            color: (viewModel.curStatus == SearchStatus.before)
              ? WakColor.grey400
              : WakColor.grey25.withOpacity(0.6)),
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
                  _fieldText.clear();
                  viewModel.updateStatus(SearchStatus.before);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 45,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: WakColor.grey200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '취소',
                        style: WakText.txt12B.copyWith(color: WakColor.grey400),
                      ),
                    ),
                  ),
                ),
              )
            : null,
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
                  style: WakText.txt16B.copyWith(color: WakColor.grey900),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
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
        physics: const ScrollPhysics(),
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
                    _fieldText.text = viewModel.history[idx];
                    viewModel.search(_fieldText.text);
                  },
                  child: Text(
                    viewModel.history[idx],
                    style: WakText.txt14MH.copyWith(color: WakColor.grey900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => viewModel.removeHistory(idx),
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
    SearchViewModel viewModel = Provider.of<SearchViewModel>(context);
    return FutureBuilder<List<List<Song>>>(
      future: Future.wait(
          [viewModel.list[SearchType.title]!, viewModel.list[SearchType.artist]!, viewModel.list[SearchType.remix]!]),
      builder: (_, snapshot) {
        return DefaultTabController(
          length: 4,
          child: Builder(
            builder: (context) {
              _tabCtrl = DefaultTabController.of(context);
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 54,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: WakColor.grey200),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: TabBar(
                          controller: _tabCtrl,
                          indicatorColor: (snapshot.hasData) ? WakColor.lightBlue : Colors.transparent,
                          labelStyle: WakText.txt16B,
                          unselectedLabelStyle: WakText.txt16M,
                          labelColor: WakColor.grey900,
                          unselectedLabelColor: WakColor.grey400,
                          overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          splashFactory: NoSplash.splashFactory,
                          labelPadding: EdgeInsets.zero,
                          tabs: List.generate(
                            4,
                            (idx) => Container(
                              height: 36,
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 10),
                              child: (snapshot.hasData)
                                ? Text(
                                    (idx == 0) ? '전체' : SearchType.values[idx - 1].str,
                                    textAlign: TextAlign.center,
                                  )
                                : SkeletonText(wakTxtStyle: WakText.txt16B, width: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: List.generate(
                        4,
                        (idx) {
                          if (idx == 0) {
                            return _buildTotalTab(context, (snapshot.hasData) ? snapshot.data! : List.filled(3, [null, null, null]));
                          } else {
                            return _buildTab(context, (snapshot.hasData) ? snapshot.data![idx - 1] : List.filled(20, null));
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        );
      },
    );
  }

  Widget _buildTotalTab(BuildContext context, List<List<Song?>> list) {
    List<int> tabs = [];
    for (int tabIdx = 0; tabIdx < 3; tabIdx++) {
      if (list[tabIdx].isNotEmpty) tabs.add(tabIdx);
    }
    if (tabs.isEmpty) {
      return const ErrorInfo(errorMsg: '검색 결과가 없습니다.');
    } else if (tabs.length == 1) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: list[tabs[0]].length + 1,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return _buildTabHeader(context, tabs[0], list[tabs[0]].length, true);
          }
          return SongTile(
            song: list[tabs[0]][idx - 1],
            tileType: TileType.dateTile,
          );
        },
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: tabs.length,
        itemBuilder: (context, idx) => Column(
          children: [
            _buildTabHeader(context, tabs[idx], list[tabs[idx]].length, list[tabs[idx]][0] != null),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3, 
                (songIdx) {
                  if (list[tabs[idx]].length > songIdx) {
                    return SongTile(
                      song: list[tabs[idx]][songIdx],
                      tileType: TileType.dateTile,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
      );
    }
  }

  Widget _buildTabHeader(BuildContext context, int tabIdx, int length, bool hasData) {
    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            SkeletonText(wakTxtStyle: WakText.txt16M, width: 28),
            const SizedBox(width: 4),
            SkeletonText(wakTxtStyle: WakText.txt16M, width: 20),
            const Spacer(),
            SkeletonText(wakTxtStyle: WakText.txt12MH, width: 56),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            Text(
              SearchType.values[tabIdx].str,
              style: WakText.txt16M.copyWith(color: WakColor.grey900),
            ),
            const SizedBox(width: 4),
            Text(
              length.toString(),
              style: WakText.txt16M.copyWith(color: WakColor.lightBlue),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _tabCtrl!.animateTo(tabIdx + 1),
              child: Row(
                children: [
                  Text(
                    '전체보기',
                    style: WakText.txt12MH.copyWith(color: WakColor.grey900),
                    textAlign: TextAlign.right,
                  ),
                  SvgPicture.asset(
                    'assets/icons/ic_16_arrow_right.svg',
                    width: 16,
                    height: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTab(BuildContext context, List<Song?> list) {
    if (list.isEmpty) {
      return const ErrorInfo(errorMsg: '검색 결과가 없습니다.');
    } else {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        itemBuilder: (_, idx) => SongTile(
          song: list[idx],
          tileType: TileType.dateTile,
        ),
      );
    }
  }
}
