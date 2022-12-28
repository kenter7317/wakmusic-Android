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
  late Map<TabName, Future<List<Song>>> _newList;

  TabName get curTabName => _tabName;
  Future<List<Song>> get topList => _topList;
  Map<TabName, Future<List<Song>>> get newList => _newList;

  HomeViewModel() {
    _api = API();
    _newList = {};
    getList();
  }

  Future<void> getList() async {
    _topList = _api.fetchTop(type: ChartType.hourly, length: 5);
    for (TabName tab in TabName.values) {
      _newList[tab] = _api.fetchTop(type: ChartType.values[TabName.values.indexOf(tab)], length: 20); /* fetchTop <= for test */
    }
    notifyListeners();
  }

  void updateTab(TabName tabName) {
    _tabName = tabName;
    notifyListeners();
  }
}