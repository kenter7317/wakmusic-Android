import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/repository/notice_repo.dart';
import 'package:wakmusic/screens/charts/charts_view.dart';
import 'package:wakmusic/utils/error_catch.dart';
import 'package:wakmusic/utils/status_nav_color.dart';
import 'package:wakmusic/widgets/common/main_bot_nav.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/screens/artists/artists_list_view.dart';
import 'package:wakmusic/style/theme.dart';
import 'package:wakmusic/models/providers/providers.dart';
import 'package:wakmusic/screens/splash.dart';
import 'package:wakmusic/screens/home/home_view.dart';
import 'package:wakmusic/screens/search/search_view.dart';
import 'package:wakmusic/screens/keep/keep_view.dart';
import 'package:wakmusic/widgets/common/pop_up.dart';
import 'package:wakmusic/widgets/show_modal.dart';
import 'package:wakmusic/widgets/common/toast_msg.dart';

void main() async {
  runZonedGuarded(() async {
    await dotenv.load();
    runApp(const MyApp());
  }, ErrorCatch.call);
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
    const ChartsView(),
    SearchView(),
    const ArtistsListView(),
    const KeepView(),
  ];

  final navKeyList = List.generate(5, (index) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    ErrorCatch.method = (error, stack) {
      showToastWidget(
        context: context,
        position: const StyledToastPosition(
          align: Alignment.bottomCenter,
          offset: 56,
        ),
        animation: StyledToastAnimation.slideFromBottomFade,
        reverseAnimation: StyledToastAnimation.fade,
        ToastMsg(msg: 'Error: $error StackTrace: $stack', size: 120),
      );
    };

    super.initState();
    final repo = NoticeRepository();

    repo.getNoticeDisplay().then((notices) async {
      for (final n in notices) {
        await showModal(
          context: context,
          builder: (_) => PopUp(
            type: PopUpType.contentBtn,
            msg: n.images.isNotEmpty ? n.images[0] : null,
            negFunc: () => repo.hideNotice(n),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
      }
    });
  }

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
                if (page == navList[botNav.curIdx]) {
                  botNav.setPageContext(context);
                }
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
            const SizedBox(height: 100),
            TextButton(
              onPressed: () {
                botNav.mainSwitch();
              },
              child: const Text('botNav 온오프'),
            ),
            TextButton(
              onPressed: () {
                botNav.subSwitch();
              },
              child: const Text('subNav 온오프'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(0);
              },
              child: const Text('노래 세부 정리'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(1);
              },
              child: const Text('노래 재생'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(2);
              },
              child: const Text('노래 서브 재생'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(3);
              },
              child: const Text('재생목록 편집'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(4);
              },
              child: const Text('차트 편집'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(5);
              },
              child: const Text('보관함 편집'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(6);
              },
              child: const Text('보관함 상세'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(7);
              },
              child: const Text('보관함 노래 추가'),
            ),
            TextButton(
              onPressed: () {
                botNav.subChange(8);
              },
              child: const Text('보관함 프로필 편집'),
            ),
          ],
        ),
      ),
    );
  }
}
