import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

enum TabName {
  total('전체'),
  woowakgood('우왁굳'),
  isedol('이세돌'),
  gomem('고멤');

  const TabName(this.locale);
  final String locale;
}

class HomeViewModel with ChangeNotifier {
  TabName _tabName = TabName.total;
  late final API _api;
  late Future<List<Song>> _topList;
  late Map<TabName, Future<List<Song>>> _newLists;
  late Map<TabName, List<Song?>> _prevLists;

  TabName get curTabName => _tabName;
  Future<List<Song>> get topList => _topList;
  Map<TabName, Future<List<Song>>> get newLists => _newLists;
  Map<TabName, List<Song?>> get prevLists => _prevLists;

  HomeViewModel() {
    _api = API();
    _newLists = {};
    _prevLists = {};
    getList();
  }

  void sync() async {
    for (TabName tabName in TabName.values) {
      try {
        _prevLists[tabName] = [...await  _newLists[tabName]!];
      } catch(_) {
        _prevLists[tabName] = List.filled(10, null);
      }
    }
  }

  Future<void> getList() async {
    _topList = _api.fetchTop(type: ChartType.hourly);
    sync();
    for (TabName tabName in TabName.values) {
      _newLists[tabName] = _api.fetchTop(type: ChartType.values[TabName.values.indexOf(tabName)], length: 10); /* fetchTop <= for test */
    }
    notifyListeners();
  }

  void updateTab(TabName tabName) {
    _tabName = tabName;
    sync();
    notifyListeners();
  }
}