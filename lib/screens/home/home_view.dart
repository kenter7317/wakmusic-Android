import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/rec_playlist.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final ScrollController _controller = ScrollController();

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
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    return Stack(
      children: [
        Positioned(
          top: -34,
          right: -73,
          child: Container(
            width: 276,
            height: 276,
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
          onRefresh: () => viewModel.getList(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildNew(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
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
          child: Column(
            children: [
              _buildChartTitle(context),
              const SizedBox(height: 20),
              SizedBox(
                height: 274,
                child: FutureBuilder<List<Song>>(
                  future: viewModel.topList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (idx) => SongTile(
                            song: snapshot.data![idx],
                            tileType: TileType.homeTile,
                            rank: idx + 1,
                          ),
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartTitle(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              /* go to chart page */
            },
            child: Row(
              children: [
                Text(
                  '왁뮤차트 TOP100',
                  style: WakText.txt16B.copyWith(color: WakColor.grey900),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/ic_16_arrow_right.svg',
                  color: WakColor.grey900,
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              /* play all the songs */
            },
            child: Text(
              '전체듣기',
              style: WakText.txt14MH.copyWith(color: WakColor.grey25),
              textAlign: TextAlign.right,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNew(BuildContext context) {
    HomeViewModel viewModel = Provider.of<HomeViewModel>(context);
    return SizedBox(
      height: 174,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Text(
                    '최신 음악',
                    style: WakText.txt16B.copyWith(color: WakColor.grey900),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildNewTab(context, TabName.total),
                      _buildNewTab(context, TabName.woowakgood),
                      _buildNewTab(context, TabName.isedol),
                      _buildNewTab(context, TabName.gomem),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 130,
            child: FutureBuilder<List<Song>>(
              future: viewModel.newList[viewModel.curTabName],
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 20,
                    itemBuilder: (context, idx) {
                      return _buildNewListItem(context, snapshot.data![idx]);
                    },
                    separatorBuilder: (context, idx) {
                      return const SizedBox(width: 8);
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTab(BuildContext context, TabName tabName) {
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
          style: tabName == viewModel.curTabName
              ? WakText.txt14B.copyWith(color: WakColor.grey900)
              : WakText.txt14L
                  .copyWith(color: WakColor.grey900.withOpacity(0.6)),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildNewListItem(BuildContext context, Song song) {
    return SizedBox(
      width: 144,
      height: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ExtendedImage.network(
                'https://i.ytimg.com/vi/${song.id}/hqdefault.jpg',
                fit: BoxFit.cover,
                width: 144,
                height: 80,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState != LoadState.completed) {
                    return Image.asset("assets/images/img_80_thumbnail.png");
                  }
                },
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
