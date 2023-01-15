import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/home/home_view.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:wakmusic/screens/splash.dart';
import 'package:wakmusic/style/theme.dart';
import 'package:wakmusic/screens/search/search_view.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';

void main() {
  runApp(const MaterialApp(home: Splash()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => SelectSongProvider()),
        ChangeNotifierProvider(create: (_) => RecPlaylistProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!
          );
        },
        theme: WakTheme.wakTheme,
        home: const Main(),
      ),
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    return SearchView();
  }
}