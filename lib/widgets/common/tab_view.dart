import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/audio_provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/models/providers/select_playlist_provider.dart';
import 'package:wakmusic/models/providers/select_song_provider.dart';
import 'package:wakmusic/models/providers/tab_provider.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';
import 'package:wakmusic/widgets/common/skeleton_ui.dart';

enum TabType {
  maxTab(
    TabBarIndicatorSize.tab,
    EdgeInsets.zero,
    EdgeInsets.fromLTRB(20, 16, 20, 0),
    false,
  ),
  minTab(
    TabBarIndicatorSize.label,
    EdgeInsets.symmetric(horizontal: 12),
    EdgeInsets.fromLTRB(8, 16, 8, 0),
    true,
  );

  const TabType(
    this.indicatorSize,
    this.labelPadding,
    this.padding,
    this.isScrollable,
  );
  final TabBarIndicatorSize indicatorSize;
  final EdgeInsetsGeometry labelPadding;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
}

class TabView extends StatelessWidget {
  const TabView({
    super.key,
    required this.type,
    required this.tabBarList,
    required this.tabViewList,
    this.physics = const BouncingScrollPhysics(),
    this.listener,
  });
  final TabType type;
  final List<String> tabBarList;
  final List<Widget> tabViewList;
  final ScrollPhysics physics;
  final void Function()? listener;

  @override
  Widget build(BuildContext context) {
    int length = tabBarList.length;
    final tabProvider = Provider.of<TabProvider>(context);
    final selProvider = Provider.of<SelectSongProvider>(context);
    final selListProvider = Provider.of<SelectPlaylistProvider>(context);
    final navProvider = Provider.of<NavProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return DefaultTabController(
      length: length,
      child: Builder(builder: (context) {
        TabController controller = DefaultTabController.of(context)!;
        if (!controller.hasListeners && listener != null) {
          controller.addListener(() {
            if (controller.previousIndex != controller.index) {
              listener!();
            }
          });
        }
        controller.addListener(() {
          if (controller.previousIndex != controller.index) {
            tabProvider.update(controller.index);
            selProvider.clearList();
            selListProvider.clearList();
            if (audioProvider.isEmpty) {
              navProvider.subSwitchForce(false);
            } else {
              navProvider.subChange(1);
            }
          }
        });
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 52,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: WakColor.grey200),
                    ),
                  ),
                ),
                TabBar(
                  indicatorColor: WakColor.lightBlue,
                  labelStyle: WakText.txt16B,
                  unselectedLabelStyle: WakText.txt16M,
                  labelColor: WakColor.grey900,
                  unselectedLabelColor: WakColor.grey400,
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: type.indicatorSize,
                  labelPadding: type.labelPadding,
                  padding: type.padding,
                  isScrollable: type.isScrollable,
                  tabs: List.generate(
                    length,
                    (idx) => Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 34,
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                      child: Text(
                        tabBarList[idx],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: physics,
                children: tabViewList,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class TabSkeletonView extends StatelessWidget {
  const TabSkeletonView({
    super.key,
    required this.type,
    required this.tabLength,
    required this.tabViewList,
    this.physics = const BouncingScrollPhysics(),
  });
  final TabType type;
  final int tabLength;
  final List<Widget> tabViewList;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabLength,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 52,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: WakColor.grey200),
                  ),
                ),
              ),
              TabBar(
                indicatorColor: WakColor.lightBlue,
                labelStyle: WakText.txt16B,
                unselectedLabelStyle: WakText.txt16M,
                labelColor: WakColor.grey900,
                unselectedLabelColor: WakColor.grey400,
                overlayColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                indicatorSize: type.indicatorSize,
                labelPadding: type.labelPadding,
                padding: type.padding,
                isScrollable: type.isScrollable,
                tabs: List.generate(
                  tabLength,
                  (idx) => Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: 34,
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                    child: Center(
                        child: SkeletonText(
                            wakTxtStyle: WakText.txt16M,
                            width: (idx == 0) ? 28 : 64)),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: physics,
              children: tabViewList,
            ),
          ),
        ],
      ),
    );
  }
}
