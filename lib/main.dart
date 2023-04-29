import 'package:flutter/material.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/screens/charts/charts_view.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/common/main_bot_nav.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/screens/artists/artists_list_view.dart';
import 'package:wakmusic/style/theme.dart';
import 'package:wakmusic/models/providers/providers.dart';
import 'package:wakmusic/screens/splash.dart';
import 'package:wakmusic/screens/home/home_view.dart';
import 'package:wakmusic/screens/search/search_view.dart';
import 'package:wakmusic/screens/keep/keep_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Providers(
      child: MaterialApp(
        title: '왁타버스 뮤직',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        theme: WakTheme.wakTheme,
        home: const Splash(),
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final List<Widget> navList = [
    HomeView(),
    ChartsView(),
    SearchView(),
    ArtistsListView(),
    KeepView(),
  ];

  final navKeyList = List.generate(5, (index) => GlobalKey<NavigatorState>());

  @override
  Widget build(BuildContext context) {
    NavProvider botNav = Provider.of<NavProvider>(context);
    statusNavColor(context, ScreenType.etc);
    return Scaffold(
      body: IndexedStack(
        index: botNav.curIdx,
        children: navList.map((page) {
          return Navigator(
            key: navKeyList[navList.indexOf(page)],
            onGenerateRoute: (_) {
              return MaterialPageRoute(builder: (context) {
                if(page == navList[botNav.curIdx]) botNav.setPageContext(context);
                return page;
              });
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const MainBotNav(),
    );
  }
}

class Temp extends StatelessWidget {
  const Temp({super.key});

  @override
  Widget build(BuildContext context) {
    final botNav = Provider.of<NavProvider>(context);

    return SingleChildScrollView(
        child: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            TextButton(
                onPressed: () {
                  botNav.mainSwitch();
                },
                child: Text('botNav 온오프')),
            TextButton(
                onPressed: () {
                  botNav.subSwitch();
                },
                child: Text('subNav 온오프')),
            TextButton(
                onPressed: () {
                  botNav.subChange(0);
                },
                child: Text('노래 세부 정리')),
            TextButton(
                onPressed: () {
                  botNav.subChange(1);
                },
                child: Text('노래 재생')),
            TextButton(
                onPressed: () {
                  botNav.subChange(2);
                },
                child: Text('노래 서브 재생')),
            TextButton(
                onPressed: () {
                  botNav.subChange(3);
                },
                child: Text('재생목록 편집')),
            TextButton(
                onPressed: () {
                  botNav.subChange(4);
                },
                child: Text('차트 편집')),
            TextButton(
                onPressed: () {
                  botNav.subChange(5);
                },
                child: Text('보관함 편집')),
            TextButton(
                onPressed: () {
                  botNav.subChange(6);
                },
                child: Text('보관함 상세')),
            TextButton(
                onPressed: () {
                  botNav.subChange(7);
                },
                child: Text('보관함 노래 추가')),
            TextButton(
                onPressed: () {
                  botNav.subChange(8);
                },
                child: Text('보관함 프로필 편집'))
          ]),
    ));
  }
}
