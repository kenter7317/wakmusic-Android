import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/artists/artists_list_view.dart';
import 'package:wakmusic/screens/charts/charts_view.dart';
import 'package:wakmusic/screens/charts/charts_view_model.dart';
import 'package:wakmusic/style/theme.dart';
import 'package:wakmusic/models/providers/providers.dart';
import 'package:wakmusic/screens/splash.dart';
import 'package:wakmusic/screens/home/home_view.dart';
import 'package:wakmusic/screens/search/search_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Providers(
      child: MaterialApp(
        title: '왁타버스뮤직',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!
          );
        },
        theme: WakTheme.wakTheme,
        home: const Splash(),
      ),
    );
  }
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArtistsListView(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        child: Container(
          height: 56,
          color: Colors.white,
        ),
      ),
    );
  }
}