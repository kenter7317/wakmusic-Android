import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/screens/artists/artist_detail_view.dart';
import 'package:wakmusic/screens/artists/artists_view_model.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter/services.dart';

class ArtistsListView extends StatelessWidget {
  const ArtistsListView({super.key});

  @override
  Widget build(BuildContext context) {
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
        child: FutureBuilder(
            future: viewModel.artistsList,
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Expanded(
                      child: MasonryGridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 2,
                          itemCount: snapshot.data!.length + 2,
                          itemBuilder: (context, index) {
                            if (index == 0 || index == 2) {
                              return Container(
                                  height: ((MediaQuery.of(context).size.width -
                                                  56) /
                                              3) /
                                          106 *
                                          79 -
                                      12);
                            } else if (index == 1) {
                              return artistListTile(
                                  context, snapshot.data![index - 1]);
                            } else {
                              return artistListTile(
                                  context, snapshot.data![index - 2]);
                            }
                          }),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: MasonryGridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          itemCount: 33,
                          itemBuilder: (context, index) {
                            if (index == 0 || index == 2) {
                              return Container(
                                  height: ((MediaQuery.of(context).size.width -
                                                  56) /
                                              3) /
                                          106 *
                                          79 -
                                      12);
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: ((MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        56) /
                                                    3) /
                                                106 *
                                                130 -
                                            (MediaQuery.of(context).size.width -
                                                    56) /
                                                3),
                                    child: SkeletonBox(
                                        child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(90),
                                          color: WakColor.grey200),
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  56) /
                                              3,
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  56) /
                                              3,
                                    )),
                                  ),
                                  const SizedBox(height: 4),
                                  SkeletonText(
                                    wakTxtStyle: WakText.txt14MH,
                                    width: 50,
                                  )
                                ],
                              );
                            }
                          }),
                    ),
                  ],
                );
              }
            })),
      ),
    );
  }

  Widget artistListTile(
    BuildContext context,
    Artist artist, {
    bool loading = false,
  }) {
    ArtistsViewModel viewModel = Provider.of<ArtistsViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ZoomTapAnimation(
          onTap: () {
            viewModel.setArtist(artist);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArtistView(artist: artist)),
            );
          },
          child: ExtendedImage.network(
            artist.roundImage,
            width: (MediaQuery.of(context).size.width - 56) / 3,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState != LoadState.completed) {
                final width = (MediaQuery.of(context).size.width - 56) / 3;
                return Padding(
                  padding: EdgeInsets.only(top: width / 106 * 130 - width),
                  child: SkeletonBox(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        color: WakColor.grey200,
                      ),
                      width: width,
                      height: width,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          artist.name,
          style: WakText.txt14MH.copyWith(color: WakColor.grey600),
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
