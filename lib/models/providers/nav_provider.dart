import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';

class IdxProvider extends ChangeNotifier {
  int _idx = 0;
  int get curIdx => _idx;

  void update(int idx) {
    _idx = idx;
    notifyListeners();
  }
}

enum AppScreen {
  home,
  charts,
  search,
  artists,
  inventory;

  static String name(int i) => values[i].name;
}

class NavProvider extends IdxProvider {
  bool _mainState = true;
  bool get mainState => _mainState;

  bool _subState = false;
  bool get subState => _subState;

  int _subIdx = 0;
  int get subIdx => _subIdx;

  late BuildContext _pageContext;
  BuildContext get pageContext => _pageContext;

  void setPageContext(BuildContext context) {
    _pageContext = context;
  }

  void mainSwitch() {
    _mainState = !_mainState;
    notifyListeners();
  }

  void mainSwitchForce(bool state) {
    if (_mainState != state) {
      _mainState = state;
      notifyListeners();
    }
  }

  void subSwitch() {
    _subState = !_subState;
    notifyListeners();
  }

  void subSwitchForce(bool state) {
    if (_subState != state) {
      _subState = state;
      notifyListeners();
    }
  }

  void subChange(int idx) {
    if (_subIdx != idx) {
      _subIdx = idx;
      notifyListeners();
    }
  }

  @override
  void update(int idx) {
    super.update(idx);
    FirebaseAnalytics.instance
        .setCurrentScreen(screenName: AppScreen.name(idx));
  }
}
