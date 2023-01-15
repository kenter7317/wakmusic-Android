import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/home/home_view.dart';
import 'package:wakmusic/screens/home/home_view_model.dart';
import 'package:wakmusic/style/theme.dart';
import 'package:wakmusic/screens/search/search_view.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';
import 'package:wakmusic/models/providers/rec_playlist_provider.dart';
import 'package:wakmusic/screens/playlist/playlist_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => SelectSongProvider()),
        ChangeNotifierProvider(create: (_) => RecPlaylistProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistViewModel()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!
        );
      },
      theme: WakTheme.wakTheme,
      home: const Main(),
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
    return HomeView();
  }
}