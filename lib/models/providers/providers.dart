import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:wakmusic/screens/player/player_view_model.dart';
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
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => SelectSongProvider()),
        ChangeNotifierProvider(create: (_) => RecPlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()),
        ChangeNotifierProvider(create: (_) => PlayerPlayListViewModel()),
      ],
      child: child,
    );
  }
}