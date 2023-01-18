import 'package:flutter/material.dart';
import 'package:wakmusic/style/colors.dart';
import 'package:wakmusic/style/text_styles.dart';

class TabView extends StatelessWidget {
  const TabView({super.key, required this.tabBarList, required this.tabViewList});
  final List<String> tabBarList;
  final List<Widget> tabViewList;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBarList.length,
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
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: TabBar(
                  indicatorColor: WakColor.lightBlue,
                  labelStyle: WakText.txt16B,
                  unselectedLabelStyle: WakText.txt16M,
                  labelColor: WakColor.grey900,
                  unselectedLabelColor: WakColor.grey400,
                  overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  labelPadding: EdgeInsets.zero,
                  tabs: List.generate(
                    tabBarList.length,
                    (idx) => Container(
                      height: 34,
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
                      child: Text(
                        tabBarList[idx],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: tabViewList,
            ),
          ),
        ],
      ),
    );
  }
}