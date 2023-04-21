import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

class HomeViewModel with ChangeNotifier {
  GroupType _tabName = GroupType.all;
  late final API _api;
  late Future<List<Song>> _topList;
  late Map<GroupType, Future<List<Song>>> _newLists;
  late Map<GroupType, List<Song?>> _prevLists;

  GroupType get curTabName => _tabName;
  Future<List<Song>> get topList => _topList;
  Map<GroupType, Future<List<Song>>> get newLists => _newLists;
  Map<GroupType, List<Song?>> get prevLists => _prevLists;

  HomeViewModel() {
    _api = API();
    _newLists = {};
    _prevLists = {};
    getList();
  }

  void sync() async {
    for (GroupType tabName in GroupType.values) {
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
    for (GroupType tabName in GroupType.values) {
      _newLists[tabName] = _api.fetchNew(type: tabName);
    }
    notifyListeners();
  }

  void updateTab(GroupType tabName) {
    _tabName = tabName;
    sync();
    notifyListeners();
  }
}