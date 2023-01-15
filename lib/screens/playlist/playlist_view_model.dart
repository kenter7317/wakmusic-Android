import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

enum EditStatus { none, more, editing }

class PlaylistViewModel with ChangeNotifier {
  EditStatus _status = EditStatus.none;
  String? _prevKeyword;
  late final API _api;
  late List<Song?> _songs;
  late List<Song?> _tempsongs;

  EditStatus get curStatus => _status;
  List<Song?> get songs => _songs;
  List<Song?> get tempsongs => _tempsongs;

  PlaylistViewModel() {
    _api = API();
  }

  void updateStatus(EditStatus status) {
    _status = status;
    notifyListeners();
  }

  void clear() {
    _status = EditStatus.none;
    _songs = List.filled(10, null);
    _tempsongs = [..._songs];
  }

  Future<void> getSongs(String keyword) async {
    if (keyword != _prevKeyword) {
      clear();
      _prevKeyword = keyword;
      _songs = await _api.search(keyword: keyword, type: SearchType.ids);
      _tempsongs = [..._songs];
      notifyListeners();
    }
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _tempsongs.removeAt(oldIdx);
    _tempsongs.insert(newIdx, song);
    notifyListeners();
  }

  void applySongs(bool apply) {
    if (apply) {
      _songs = [..._tempsongs];
    } else {
      _tempsongs = [..._songs];
    }
    _status = EditStatus.none;
    notifyListeners();
  }
}