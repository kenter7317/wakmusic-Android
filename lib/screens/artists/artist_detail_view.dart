import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models/providers/tab_provider.dart';
import 'package:wakmusic/screens/artists/artists_view_model.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/utils/txt_size.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/common/exitable.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key, required this.artist});
  final Artist artist;

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();
  final ScrollController descScrollController = ScrollController();
  bool infoCardFront = true;
  double descScrollHeight = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  Widget cardAnimatedBuilder(Widget widget, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: widget,
      builder: (_, widget) {
        final isBack = (ValueKey(infoCardFront) != widget!.key);
        final value = isBack ? min(rotate.value, pi / 2) : rotate.value;

        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.0025;
        tilt *= isBack ? -1.0 : 1.0;

        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  Widget artistInfoCardContainer(
      ValueKey key, double artistImgRatio, Widget widget) {
    return Container(
      key: key,
      height: artistImgRatio * 180,
      width: artistImgRatio * 187,
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        border: Border.all(color: WakColor.grey25, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    TabProvider tabProvider = Provider.of<TabProvider>(context);
    SelectSongProvider selProvider = Provider.of<SelectSongProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    NavProvider navProvider = Provider.of<NavProvider>(context);
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    final artist = widget.artist;

    tabController.addListener(() {
      if (tabController.previousIndex != tabController.index) {
        tabProvider.update(tabController.index);
        selProvider.clearList();
        if (audioProvider.isEmpty) {
          navProvider.subSwitchForce(false);
        } else {
          navProvider.subChange(1);
        }
      }
    });

    return Exitable(
      scopes: const [
        ExitScope.selectedSong,
        ExitScope.artistDetail,
      ],
      onExitable: (scope) {
        if (scope == ExitScope.selectedSong && ExitScope.artistDetail.contain) {
          () async {
            final botNav = Provider.of<NavProvider>(context, listen: false);
            final selectedList =
                Provider.of<SelectSongProvider>(context, listen: false);
            final audioProvider =
                Provider.of<AudioProvider>(context, listen: false);
            selectedList.clearList();
            botNav.subChange(1);
            if (audioProvider.isEmpty) botNav.subSwitchForce(false);
            ExitScope.remove = ExitScope.selectedSong;
          }();
          ExitScope.remove = ExitScope.artistDetail;
          Navigator.pop(context);
        }
        if (scope == ExitScope.artistDetail) {
          ExitScope.remove = ExitScope.artistDetail;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          controller: scrollController,
          clipBehavior: Clip.none,
          headerSliverBuilder: (context, isScrolled) => [
            SliverStack(
              children: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  collapsedHeight: MediaQuery.of(context).viewPadding.top + 172,
                  expandedHeight: MediaQuery.of(context).viewPadding.top + 194,
                  flexibleSpace: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).viewPadding.top + 172,
                        color: WakColor.grey100,
                      ),
                      Container(
                        height: MediaQuery.of(context).viewPadding.top + 144,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            stops: [...artist.colors.map((e) => e.stop)],
                            colors: [
                              ...artist.colors
                                  .map((e) => e.color.withOpacity(e.opacity))
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MultiSliver(
                  children: [
                    PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: SliverAppBar(
                        pinned: true,
                        toolbarHeight: 48,
                        leadingWidth: 72,
                        leading: IconButton(
                          onPressed: () {
                            ExitScope.remove = ExitScope.artistDetail;
                            Navigator.pop(context);
                            viewModel.clear();
                            selProvider.clearList();
                            if (audioProvider.isEmpty) {
                              navProvider.subSwitchForce(false);
                            } else {
                              navProvider.subChange(1);
                            }
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: SvgPicture.asset(
                              "assets/icons/ic_32_arrow_bottom.svg",
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        expandedHeight: 72 +
                            artistImgRatio *
                                180, // appBar + 8 + artistImg + 16 = 80 + artistImg
                        collapsedHeight: 48, // appBar + 8
                        shadowColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: artistInfo(context),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TabBarDelegate(tabController: tabController),
                    ),
                  ],
                ),
              ],
            ),
          ],
          body: albumsTabView(tabController, widget.artist.colors[0].color),
        ),
      ),
    );
  }

  Widget artistInfo(BuildContext context) {
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).viewPadding.top + 56, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              ExtendedImage.network(
                "${API.static.url}/artist/square/${widget.artist.id}.png"
                "?v=${widget.artist.imageVersion.square}",
                width: artistImgRatio * 140,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState != LoadState.completed) {
                    return SkeletonBox(
                      child: Container(
                        width: artistImgRatio * 140,
                        height: artistImgRatio * 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: WakColor.grey200,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                transitionBuilder:
                    (Widget widget, Animation<double> animation) {
                  return cardAnimatedBuilder(widget, animation);
                },
                layoutBuilder: (widget, list) {
                  return Stack(
                    children: [widget!, ...list],
                  );
                },
                child: artistInfoCardContainer(
                  ValueKey(infoCardFront),
                  artistImgRatio,
                  infoCardFront
                      ? artistInfoCardFront(context)
                      : artistInfoCardBack(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget artistInfoCardFront(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            artistInfoTxt(context),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.artist.appTitle,
                  style:
                      WakText.txt14MH.copyWith(overflow: TextOverflow.visible),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 4,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                infoCardFront = !infoCardFront;
              });
            },
            child: SvgPicture.asset(
              "assets/icons/ic_24_document_off.svg",
            ),
          ),
        ),
      ],
    );
  }

  Widget artistInfoCardBack(BuildContext context) {
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    return Stack(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("소개글", style: WakText.txt16B),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      infoCardFront = !infoCardFront;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SvgPicture.asset(
                      "assets/icons/ic_24_document_on.svg",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: NotificationListener(
                onNotification: (notification) {
                  descScrollController.addListener(() {
                    setState(() {
                      final pos = descScrollController.position;
                      descScrollHeight = (pos.pixels / pos.maxScrollExtent) *
                          (artistImgRatio * 120 - 80);
                    });
                  });
                  return false;
                },
                child: SingleChildScrollView(
                  controller: descScrollController,
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      widget.artist.description,
                      style: WakText.txt12L.copyWith(
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: WakColor.grey200,
                ),
                width: 2,
                height: artistImgRatio * 120,
              ),
              Positioned(
                top: descScrollHeight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: WakColor.grey600,
                  ),
                  width: 2,
                  height: 80,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget artistInfoTxt(BuildContext context) {
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    final artist = widget.artist;
    if (artist.id == "woowakgood") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist.name,
            style: WakText.txt24B,
          ),
          Text(
            artist.id.substring(0, 1).toUpperCase() + artist.id.substring(1),
            style: WakText.txt14LS
                .copyWith(color: WakColor.grey900.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (artist.id == "KCMDBYTSSG") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: artistImgRatio * 150,
            child: Stack(
              children: [
                Text(
                  "김치만두번영택\n사스가",
                  style: artistImgRatio * 123 <
                          getTxtSize("김치만두번영택", WakText.txt18B).width
                      ? WakText.txt16B
                      : WakText.txt18B,
                ),
                Positioned(
                  right: 2,
                  bottom: 4,
                  child: Text(
                    artist.id,
                    style: WakText.txt12L
                        .copyWith(color: WakColor.grey900.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                artist.group.kr,
                style: WakText.txt14MH,
              ),
              if (artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    if (artistImgRatio * 123 >
        getTxtSize(artist.name, WakText.txt24B).width +
            getTxtSize(artist.id, WakText.txt14L).width) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                artist.name,
                style: WakText.txt24B,
              ),
              const SizedBox(width: 4),
              Text(
                artist.id.substring(0, 1).toUpperCase() +
                    artist.id.substring(1),
                style: WakText.txt12L
                    .copyWith(color: WakColor.grey900.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                artist.group.kr,
                style: WakText.txt14MH,
              ),
              if (artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (getTxtSize(artist.name, WakText.txt24B).width <
              artistImgRatio * 123)
            Text(artist.name, style: WakText.txt24B)
          else if (getTxtSize(artist.name, WakText.txt20B).width <
              artistImgRatio * 123)
            Text(artist.name, style: WakText.txt20B)
          else if (getTxtSize(artist.name, WakText.txt18B).width <
              artistImgRatio * 123)
            Text(artist.name, style: WakText.txt18B)
          else
            Text(artist.name, style: WakText.txt16B),
          Text(
            artist.id.substring(0, 1).toUpperCase() + artist.id.substring(1),
            style: WakText.txt14LS
                .copyWith(color: WakColor.grey900.withOpacity(0.6)),
          ),
          getTxtSize(artist.name, WakText.txt20B).width < artistImgRatio * 123
              ? const SizedBox(height: 12)
              : const SizedBox(height: 16),
          Row(
            children: [
              Text(
                artist.group.kr,
                style: WakText.txt14MH,
              ),
              if (artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    }
  }

  Widget albumsTabView(TabController tabController, Color color) {
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    SelectSongProvider selProvider = Provider.of<SelectSongProvider>(context);

    if (viewModel.albums[AlbumType.values[tabController.index]] == null) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemCount: 10,
        itemBuilder: (_, idx) => const SkeletonBox(
          child: SongTile(
            song: null,
            tileType: TileType.dateTile,
          ),
        ),
      );
    } else {
      return TabBarView(
        controller: tabController,
        children: AlbumType.values.map((type) {
          return Stack(
            key: PageStorageKey(type.index),
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: viewModel.albums[type] == null
                    ? 0
                    : viewModel.albums[type]!.length +
                        (viewModel.isLastAlbum[type.index] ? 0 : 1),
                itemBuilder: (_, idx) {
                  if (idx == viewModel.albums[type]!.length) {
                    viewModel.getAlbums(type, idx).then((_) =>
                        selProvider.setMaxSel(viewModel.albums[type]!.length));
                  }
                  if (idx == viewModel.albums[type]!.length &&
                      !viewModel.isLastAlbum[type.index]) {
                    return const Center(
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: WakColor.grey300,
                          ),
                        ),
                      ),
                    );
                  }
                  return SongTile(
                    song: viewModel.albums[type]![idx],
                    tileType: TileType.dateTile,
                  );
                },
              ),
            ],
          );
        }).toList(),
      );
    }
  }
}

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  const TabBarDelegate({required this.tabController});
  final TabController tabController;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 36,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: WakColor.grey200),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  controller: tabController,
                  indicatorColor: WakColor.lightBlue,
                  labelStyle: WakText.txt16B,
                  unselectedLabelStyle: WakText.txt16M,
                  labelColor: WakColor.grey900,
                  unselectedLabelColor: WakColor.grey400,
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  labelPadding: EdgeInsets.zero,
                  tabs: AlbumType.values.map((type) {
                    return Tab(
                      height: 34,
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                        child: Text(
                          type.kor,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          PlayBtns(
            listCallback: () async =>
                Provider.of<ArtistsViewModel>(
                  context,
                  listen: false,
                ).albums[AlbumType.values[tabController.index]] ??
                [],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 124;

  @override
  double get minExtent => 124;

  @override
  bool shouldRebuild(covariant oldDelegate) => false;
}
