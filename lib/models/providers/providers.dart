import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/charts/charts_view_model.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:wakmusic/screens/faq/faq_view_model.dart';
import 'package:wakmusic/screens/player/player_view_model.dart';
import 'package:wakmusic/screens/keep/keep_view_model.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';

import '../../screens/player/player_playlist_view_model.dart';

class Providers extends StatelessWidget {
  const Providers({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ChartsViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ChartsViewModel()),
        ChangeNotifierProvider(create: (_) => KeepViewModel()),
        ChangeNotifierProvider(create: (_) => FAQViewModel()),
        ChangeNotifierProvider(create: (_) => PlaylistViewModel()),
        ChangeNotifierProvider(create: (_) => SelectSongProvider()),
        ChangeNotifierProvider(create: (_) => SelectPlaylistProvider()),
        ChangeNotifierProvider(create: (_) => RecPlaylistProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()),
        ChangeNotifierProvider(create: (_) => PlayerPlayListViewModel()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: child,
    );
  }
}
