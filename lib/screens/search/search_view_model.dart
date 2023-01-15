import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

enum SearchStatus { before, during, after }

class SearchViewModel extends ChangeNotifier {
  SearchStatus _status = SearchStatus.before;
  List<String> _history = [];
  late final API _api;
  late Map<SearchType, Future<List<Song>>> _resultLists;
  
  SearchStatus get curStatus => _status;
  List<String> get history => _history;
  Map<SearchType, Future<List<Song>>> get resultLists => _resultLists;

  SearchViewModel() {
    _api = API();
    _resultLists = {};
    getHistory();
  }

  Future<void> search(String keyword) async {
    for (SearchType type in SearchType.values) {
      if (type == SearchType.ids) continue;
      _resultLists[type] = _api.search(keyword: keyword, type: type);
    }
    _status = SearchStatus.after;
    addHistory(keyword);
  }

  void updateStatus(SearchStatus status) {
    _status = status;
    notifyListeners();
  }
  
  Future<void> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList('history') ?? _history;
    notifyListeners();
  }

  void addHistory(String keyword) {
    if (_history.contains(keyword)) _history.remove(keyword);
    _history.insert(0, keyword);
    _history = _history.sublist(0, min(10, _history.length));
    updateHistory();
  }

  void removeHistory(int idx) {
    _history.removeAt(idx);
    updateHistory();
  }

  void clearHistory() {
    _history.clear();
    updateHistory();
  }

  Future<void> updateHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
    notifyListeners();
  }
}
