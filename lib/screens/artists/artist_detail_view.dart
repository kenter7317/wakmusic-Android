import 'package:extended_image/extended_image.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/models_v2/scope.dart';
import 'package:wakmusic/screens/artists/artists_view_model.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flip_card/flip_card.dart';
import 'package:wakmusic/utils/txt_size.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';
import 'package:wakmusic/widgets/exitable.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key, required this.artist});
  final Artist artist;

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> with TickerProviderStateMixin {
  late FlipCardController cardController;
  late TabController tabController;
  final scrollControllers = List.generate(3, (idx) => ScrollController());
  final ScrollController descScrollController = ScrollController();
  bool hideArtistInfo = false;
  double descScrollHeight = 0;
  double opacity = 1;

  @override
  void initState() {
    super.initState();
    cardController = FlipCardController();
    tabController = TabController(length: 3, vsync: this);
    for (var controller in scrollControllers) {
      controller.addListener(() {
        setState(() {
          double offset = controller.offset;
          if (offset < 0) {
            offset = 0;
          } else if (offset > 100) {
            offset = 100;
          }
          opacity = 1 - offset / 100;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    final artist = widget.artist;
    return Exitable(
      onExitable: (scope) {
        if (scope == ExitScope.artistDetail) {
          ExitScope.remove = ExitScope.artistDetail;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            albumsTabView(tabController),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: [...artist.colors.map((e) => e.stop)],
                  colors: [
                    ...artist.colors.map((e) => e.color.withOpacity(e.opacity))
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: () {
                final ctrl = scrollControllers[tabController.index];
                return ctrl.hasClients ? -ctrl.position.pixels : 0.0;
              }(),
              child: Opacity(
                opacity: opacity,
                child: artistInfo(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).viewPadding.top + 8,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  ExitScope.remove = ExitScope.artistDetail;
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  "assets/icons/ic_32_arrow_bottom.svg",
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top +
                    56 +
                    () {
                      final ctrl = scrollControllers[tabController.index];
                      final ratio = artistImgRatio * 180 + 24;
                      if (!ctrl.hasClients) {
                        return ratio;
                      }
                      if (ratio <= ctrl.position.pixels) {
                        return 0;
                      }
                      return ratio - ctrl.position.pixels;
                    }(),
              ),
              child: Column(
                children: [
                  albumsTabBar(tabController),
                  const PlayBtns(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget artistInfo(BuildContext context) {
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).viewPadding.top + 58, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              ExtendedImage.network(
                "${API.static.url}/artist/square/${widget.artist.id}.png"
                "?v=${widget.artist.imageVersion.square}",
                width: artistImgRatio * 140,
              ),
              const SizedBox(width: 8),
              FlipCard(
                controller: cardController,
                flipOnTouch: false,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  height: artistImgRatio * 180,
                  width: artistImgRatio * 187,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    border: Border.all(color: WakColor.grey25, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          artistInfoCard(context),
                          Text(
                            widget.artist.appTitle,
                            style: WakText.txt14MH
                                .copyWith(overflow: TextOverflow.visible),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 4,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => cardController.toggleCard(),
                          child: SvgPicture.asset(
                            "assets/icons/ic_24_document_off.svg",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                back: Container(
                  height: artistImgRatio * 180,
                  width: artistImgRatio * 187,
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    border: Border.all(color: WakColor.grey25, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("소개글", style: WakText.txt16B),
                              GestureDetector(
                                onTap: () => cardController.toggleCard(),
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
                                    descScrollHeight =
                                        (pos.pixels / pos.maxScrollExtent) *
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget artistInfoCard(BuildContext context) {
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
            width: 131,
            child: Stack(
              children: [
                Text(
                  "김치만두번영택\n사스가",
                  style: WakText.txt18B,
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

    if (127 >
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
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (getTxtSize(artist.name, WakText.txt24B).width < 131)
          Text(artist.name, style: WakText.txt24B)
        else if (getTxtSize(artist.name, WakText.txt20B).width < 131)
          Text(artist.name, style: WakText.txt20B)
        else
          Text(artist.name, style: WakText.txt18B),
        Text(
          artist.id.substring(0, 1).toUpperCase() + artist.id.substring(1),
          style: WakText.txt14LS
              .copyWith(color: WakColor.grey900.withOpacity(0.6)),
        ),
        getTxtSize(artist.name, WakText.txt20B).width < 131
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

  Widget albumsTabBar(TabController tabController) {
    return Stack(
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
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            labelPadding: EdgeInsets.zero,
            tabs: AlbumType.values.map((e) {
              return Tab(
                height: 34,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                  child: Text(e.kor, textAlign: TextAlign.center),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget albumsTabView(TabController tabController) {
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;
    return TabBarView(
      controller: tabController,
      children: AlbumType.values.map((type) {
        return Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top +
                172 +
                () {
                  final ctrl = scrollControllers[tabController.index];
                  final ratio = artistImgRatio * 180 + 24;
                  if (!ctrl.hasClients) {
                    return ratio;
                  }
                  if (ratio <= ctrl.position.pixels) {
                    return 0;
                  }
                  return ratio - ctrl.position.pixels;
                }(),
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: ListView.builder(
            controller: scrollControllers[tabController.index],
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: viewModel.albums[type] == null
                ? 0
                : viewModel.albums[type]!.length +
                    (viewModel.isLastAlbum[type.index] ? 0 : 1),
            itemBuilder: (_, idx) {
              if (idx == viewModel.albums[type]!.length) {
                viewModel.getAlbums(type, idx);
                if (!viewModel.isLastAlbum[type.index]) {
                  return const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              }
              return SongTile(
                song: viewModel.albums[type]![idx],
                tileType: TileType.dateTile,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
