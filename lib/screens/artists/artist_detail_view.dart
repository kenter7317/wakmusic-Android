import 'package:extended_image/extended_image.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/artist.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models/providers/tab_provider.dart';
import 'package:wakmusic/screens/artists/artists_view_model.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:flip_card/flip_card.dart';
import 'package:wakmusic/utils/txt_size.dart';
import 'package:wakmusic/widgets/common/play_btns.dart';
import 'package:wakmusic/widgets/common/song_tile.dart';

class ArtistView extends StatefulWidget {
  const ArtistView({super.key, required this.artist});
  final Artist artist;

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> with TickerProviderStateMixin {
  late FlipCardController cardController;
  late TabController tabController;
  final List<ScrollController> scrollControllers =
      List.generate(3, (idx) => ScrollController());
  final ScrollController descScrollController = ScrollController();
  bool hideArtistInfo = false;
  double descScrollHeight = 0;
  double opacity = 1;

  @override
  void initState() {
    super.initState();
    cardController = FlipCardController();
    tabController = TabController(length: 3, vsync: this);
    for (ScrollController scrollController in scrollControllers) {
      scrollController.addListener(() {
        setState(() {
          double offset = scrollController.offset;
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
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    TabProvider tabProvider = Provider.of<TabProvider>(context);
    SelectSongProvider selProvider = Provider.of<SelectSongProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    NavProvider navProvider = Provider.of<NavProvider>(context);
    double artistImgRatio = (MediaQuery.of(context).size.width - 48) / 327;

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

    return Scaffold(
      body: Stack(
        children: [
          albumsTabView(tabController),
          Container(
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      stops: List.generate(widget.artist.colors.length,
                          (idx) => double.parse(widget.artist.colors[idx][2])),
                      colors: List.generate(
                          widget.artist.colors.length,
                          (idx) => Color(int.parse(
                                  "0xFF${widget.artist.colors[idx][0]}"))
                              .withOpacity(
                                  int.parse(widget.artist.colors[idx][1]) *
                                      0.6 /
                                      100)),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter))),
          Positioned(
              top: scrollControllers[tabController.index].hasClients
                  ? -scrollControllers[tabController.index].position.pixels
                  : 0,
              child: Opacity(opacity: opacity, child: artistInfo(context))),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 20,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  "assets/icons/ic_32_arrow_bottom.svg",
                  width: 32,
                  height: 32,
                )),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top +
                  56 +
                  (scrollControllers[tabController.index].hasClients
                      ? ((scrollControllers[tabController.index]
                                  .position
                                  .pixels <
                              (artistImgRatio * 180 + 24))
                          ? (artistImgRatio * 180 +
                              24 -
                              scrollControllers[tabController.index]
                                  .position
                                  .pixels)
                          : 0)
                      : (artistImgRatio * 180 + 24)),
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
                "$staticBaseUrl/artist/square/${widget.artist.id}.png"
                "?v=${widget.artist.squareImgVer}",
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
                            onTap: () {
                              cardController.toggleCard();
                            },
                            child: SvgPicture.asset(
                                "assets/icons/ic_24_document_off.svg")),
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
                                onTap: () {
                                  cardController.toggleCard();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: SvgPicture.asset(
                                      "assets/icons/ic_24_document_on.svg"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: NotificationListener(
                              onNotification: ((notification) {
                                descScrollController.addListener(() {
                                  setState(() {
                                    descScrollHeight =
                                        (descScrollController.position.pixels /
                                                descScrollController
                                                    .position.maxScrollExtent) *
                                            (artistImgRatio * 120 - 80);
                                  });
                                });
                                return false;
                              }),
                              child: SingleChildScrollView(
                                controller: descScrollController,
                                scrollDirection: Axis.vertical,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    widget.artist.description,
                                    style: WakText.txt12L.copyWith(
                                        overflow: TextOverflow.visible),
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
    if (widget.artist.id == "woowakgood") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.artist.name,
            style: WakText.txt24B,
          ),
          Text(
            widget.artist.id.substring(0, 1).toUpperCase() +
                widget.artist.id.substring(1),
            style: WakText.txt14LS
                .copyWith(color: WakColor.grey900.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
        ],
      );
    } else if (widget.artist.id == "KCMDBYTSSG") {
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
                    widget.artist.id,
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
                widget.artist.groupKr,
                style: WakText.txt14MH,
              ),
              if (widget.artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    } else if (getTxtSize(widget.artist.name, WakText.txt24B).width +
            getTxtSize(widget.artist.id, WakText.txt14L).width <
        127) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.artist.name,
                style: WakText.txt24B,
              ),
              const SizedBox(width: 4),
              Text(
                widget.artist.id.substring(0, 1).toUpperCase() +
                    widget.artist.id.substring(1),
                style: WakText.txt12L
                    .copyWith(color: WakColor.grey900.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                widget.artist.groupKr,
                style: WakText.txt14MH,
              ),
              if (widget.artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (getTxtSize(widget.artist.name, WakText.txt24B).width < 131)
            Text(widget.artist.name, style: WakText.txt24B)
          else if (getTxtSize(widget.artist.name, WakText.txt20B).width < 131)
            Text(widget.artist.name, style: WakText.txt20B)
          else
            Text(widget.artist.name, style: WakText.txt18B),
          Text(
            widget.artist.id.substring(0, 1).toUpperCase() +
                widget.artist.id.substring(1),
            style: WakText.txt14LS
                .copyWith(color: WakColor.grey900.withOpacity(0.6)),
          ),
          getTxtSize(widget.artist.name, WakText.txt20B).width < 131
              ? const SizedBox(height: 12)
              : const SizedBox(height: 16),
          Row(
            children: [
              Text(
                widget.artist.groupKr,
                style: WakText.txt14MH,
              ),
              if (widget.artist.graduated) Text(" · 졸업", style: WakText.txt14MH)
            ],
          ),
          const SizedBox(height: 12),
        ],
      );
    }
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
            tabs: List.generate(
              3,
              (idx) => Tab(
                height: 34,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                  child: Text(
                    AlbumType.values[idx].kor,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
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
        children: List.generate(
          3,
          (index) => Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top +
                    172 +
                    (scrollControllers[tabController.index].hasClients
                        ? ((scrollControllers[tabController.index]
                                    .position
                                    .pixels <
                                (artistImgRatio * 180 + 24))
                            ? (artistImgRatio * 180 +
                                24 -
                                scrollControllers[tabController.index]
                                    .position
                                    .pixels)
                            : 0)
                        : (artistImgRatio * 180 + 24)),
                bottom: MediaQuery.of(context).viewPadding.bottom,
              ),
              child: ListView.builder(
                controller: scrollControllers[tabController.index],
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: viewModel.albums[AlbumType.values[index]] == null
                    ? 0
                    : viewModel.albums[AlbumType.values[index]]!.length +
                        (viewModel.isLastAlbum[index] ? 0 : 1),
                itemBuilder: (_, idx) {
                  if (idx ==
                      viewModel.albums[AlbumType.values[index]]!.length) {
                    viewModel.getAlbums(AlbumType.values[index], idx);
                  }
                  if (idx ==
                          viewModel.albums[AlbumType.values[index]]!.length &&
                      !viewModel.isLastAlbum[index]) {
                    return const Center(
                        child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )));
                  }
                  return SongTile(
                    song: viewModel.albums[AlbumType.values[index]]![idx],
                    tileType: TileType.dateTile,
                  );
                },
              )),
        ));
  }
}
