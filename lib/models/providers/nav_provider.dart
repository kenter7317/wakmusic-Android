import 'package:flutter/cupertino.dart';

class IdxProvider extends ChangeNotifier {
  int _idx = 0;
  int get curIdx => _idx;

  void update(int idx) {
    _idx = idx;
    notifyListeners();
  }
}

class NavProvider extends IdxProvider {
  bool _mainState = true; 
  bool get mainState => _mainState;

  bool _subState = true;
  bool get subState => _subState;
  
  int _subIdx = 0;
  int get subIdx => _subIdx;

  void mainSwitch() {
    _mainState = !_mainState;
    notifyListeners();
  }

  void subSwitch() {
    _subState = !_subState;
    notifyListeners();
  }

  void subChange(int idx) {
    _subIdx = idx;
    notifyListeners();
  }
}