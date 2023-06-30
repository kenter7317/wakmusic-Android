import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakmusic/models/providers/nav_provider.dart';
import 'package:wakmusic/screens/search/search_view_model.dart';
import 'package:wakmusic/style/colors.dart';

statusNavColor(BuildContext context, ScreenType screenType) {
  NavProvider botNav = Provider.of<NavProvider>(context, listen: false);
  SearchViewModel searchViewModel =
      Provider.of<SearchViewModel>(context, listen: false);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: (botNav.subState == true &&
            botNav.subIdx >= 3 &&
            botNav.mainState == false)
        ? WakColor.lightBlue
        : (screenType == ScreenType.notice)
            ? Colors.transparent
            : Colors.white,
    systemNavigationBarIconBrightness: (botNav.subState == true &&
            botNav.subIdx >= 3 &&
            botNav.mainState == false)
        ? Brightness.light
        : Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: (screenType == ScreenType.search &&
            searchViewModel.curStatus == SearchStatus.during)
        ? Brightness.light
        : Brightness.dark,
  ));
}

enum ScreenType { etc, search, notice }
