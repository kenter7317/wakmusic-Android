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
  final List<Future<List<Song>>> _list = [];
  
  SearchStatus get curStatus => _status;
  List<String> get history => _history;
  List<Future<List<Song>>> get list => _list;

  SearchViewModel() {
    _api = API();
    getHistory();
  }

  Future<void> search(String keyword) async {
    for (int idx = 0; idx < 3; idx++) {
      if (_list.length == 3) {
        _list[idx] = _api.search(keyword, SearchType.values[idx]);
      } else {
        _list.add(_api.search(keyword, SearchType.values[idx]));
      }
    }
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
