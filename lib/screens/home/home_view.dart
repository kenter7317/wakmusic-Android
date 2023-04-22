import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/rec_playlist.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/services/api.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    double width = MediaQuery.of(context).size.width;
    statusNavColor(context, ScreenType.etc);
    return Stack(
      children: [
        Positioned(
          top: -34 * width / 375,
          right: -73 * width / 375,
          child: Container(
            width: 276 * width / 375,
            height: 276 * width / 375,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x0038E6FF), Color(0XFF00C8D2)],
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
                stops: [0.1469, 0.6148],
                //transform: GradientRotation(42.53 * math.pi / 180),
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            viewModel.updateTab(GroupType.all);
            _controller.jumpTo(0);
            viewModel.getList();
          },
          color: WakColor.lightBlue,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildChart(context),
                  ),
                  _buildNew(context),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: RecPlaylist(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          height: 354,
          padding: const EdgeInsets.fromLTRB(19, 15, 19, 19),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            border: Border.all(color: WakColor.grey25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FutureBuilder<List<Song>>(
            future: viewModel.topList,
            builder: (context, snapshot) => Column(
              children: [
                _buildChartTitle(context, (snapshot.hasData) ? snapshot.data : null),
                const SizedBox(height: 20),
                SizedBox(
                  height: 274,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (idx) => SongTile(
                        song: (snapshot.hasData) ? snapshot.data![idx] : null,
                        tileType: TileType.homeTile,
                        rank: idx + 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartTitle(BuildContext context, List<Song>? toplist) {
    NavProvider botNav = Provider.of<NavProvider>(context);
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>botNav.update(1),
            child: Row(
              children: [
                Text(
                  '왁뮤차트 TOP100',
                  style: WakText.txt16B.copyWith(color: WakColor.grey900),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/ic_16_arrow_right.svg',
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (toplist != null) {
                  /* play all the songs */
                }
              },
              child: Text(
                '전체듣기',
                style: WakText.txt14MH.copyWith(color: WakColor.grey25),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNew(BuildContext context) {
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    return SizedBox(
      height: 195,
      child: FutureBuilder<List<Song>>(
        future: viewModel.newLists[viewModel.curTabName],
        builder: (context, snapshot) {
          List<Song?> newList;
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.waiting) {
            newList = viewModel.prevLists[viewModel.curTabName]!;
          } else {
            newList = (snapshot.hasData) ? snapshot.data! : List.filled(10, null);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '최신 음악',
                          style: WakText.txt16B.copyWith(color: WakColor.grey900),
                        ),
                      ),
                      Row(
                        children: GroupType.values.map((tabName) => _buildNewTab(context, tabName)).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 131,
                child: ListView.separated(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 10,
                  itemBuilder: (context, idx) => _buildNewListItem(context, newList[idx]),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewTab(BuildContext context, GroupType tabName) {
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () {
          viewModel.updateTab(tabName);
          _controller.jumpTo(0);
        },
        child: Text(
          tabName.locale,
          style: (tabName == viewModel.curTabName)
            ? WakText.txt14B.copyWith(color: WakColor.grey900)
            : WakText.txt14L.copyWith(color: WakColor.grey900.withOpacity(0.6)),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildNewListItem(BuildContext context, Song? song) {
    AudioProvider audioProvider = Provider.of<AudioProvider>(context, listen: false);
    if (song == null) {
      return SizedBox(
        width: 144,
        height: 131,
        child: Column(
          children: [
            SkeletonBox(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: WakColor.grey200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 144,
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(wakTxtStyle: WakText.txt14MH),
                  SkeletonText(wakTxtStyle: WakText.txt12L),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 144,
        height: 131,
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () { audioProvider.addQueueItem(song, autoplay: true); },
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ExtendedImage.network(
                      'https://i.ytimg.com/vi/${song.id}/hqdefault.jpg',
                      fit: BoxFit.cover,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      loadStateChanged: (state) {
                        if (state.extendedImageLoadState != LoadState.completed) {
                          return Image.asset(
                            'assets/images/img_81_thumbnail.png',
                            fit: BoxFit.cover,
                          );
                        }
                        return null;
                      },
                      cacheMaxAge: const Duration(days: 30),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () {
                      /* play song */
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: WakColor.dark.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/ic_24_play_shadow.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 144,
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: WakText.txt14MH.copyWith(color: WakColor.grey900),
                  ),
                  Text(
                    song.artist,
                    style: WakText.txt12L.copyWith(color: WakColor.grey900),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
