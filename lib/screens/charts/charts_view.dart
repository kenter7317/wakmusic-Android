import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/charts/charts_view_model.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/error_info.dart';
import 'package:wakmusic/widgets/common/tab_view.dart';
import 'package:wakmusic/widgets/common/exitable.dart';

class ChartsView extends StatelessWidget {
  const ChartsView({super.key});

  @override
  Widget build(BuildContext context) {
    statusNavColor(context, ScreenType.etc);
    return Exitable(
      scopes: const [
        ExitScope.selectedSong,
        ExitScope.pageIsNotHome,
      ],
      onExitable: (scope) {
        final botNav = Provider.of<NavProvider>(context, listen: false);
        if (scope == ExitScope.selectedSong && botNav.curIdx == 1) {
          final selectedList =
              Provider.of<SelectSongProvider>(context, listen: false);
          final audioProvider =
              Provider.of<AudioProvider>(context, listen: false);
          selectedList.clearList();
          botNav.subChange(1);
          if (audioProvider.isEmpty) botNav.subSwitchForce(false);
          botNav.update(0);
          ExitScope.remove = ExitScope.selectedSong;
          ExitScope.remove = ExitScope.pageIsNotHome;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: TabView(
            type: TabType.maxTab,
            tabBarList: [...ChartType.values.map((e) => e.str)],
            tabViewList: [
              ...ChartType.values.map((e) => _buildTab(context, e))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, ChartType type) {
    ChartsViewModel viewModel = Provider.of<ChartsViewModel>(context);
    initializeDateFormatting('ko');
    return RefreshIndicator(
      onRefresh: () => viewModel.getCharts(),
      color: WakColor.lightBlue,
      edgeOffset: 102,
      child: Column(
        children: [
          const PlayBtns(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 4),
            child: FutureBuilder<DateTime>(
              future: viewModel.updatedTime[type],
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_16_check.svg',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        DateFormat('MM월 dd일 a hh시 업데이트', 'ko')
                            .format(snapshot.data!),
                        style: WakText.txt12L.copyWith(color: WakColor.grey600),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      SkeletonBox(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: WakColor.grey200,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      SkeletonText(wakTxtStyle: WakText.txt12L, width: 132),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: viewModel.charts[type],
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
                      tileType: TileType.chartTile,
                      rank: idx + 1,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
