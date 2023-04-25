import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

enum EditStatus { none, more, editing }

class PlaylistViewModel with ChangeNotifier {
  EditStatus _status = EditStatus.none;
  late StreamController<bool> _isScrolled;
  bool _prevIsScrolled = false;
  String? _prevKeyword;
  late final API _api;
  late List<Song?> _songs;
  late List<Song?> _tempsongs;

  EditStatus get curStatus => _status;
  StreamController<bool> get isScrolled => _isScrolled;
  List<Song?> get songs => _songs;
  List<Song?> get tempsongs => _tempsongs;

  PlaylistViewModel() {
    _isScrolled = StreamController<bool>.broadcast();
    _api = API();
  }

  void updateStatus(EditStatus status) {
    _status = status;
    notifyListeners();
  }

  void updateScroll(bool isScrolled) {
    if (isScrolled != _prevIsScrolled) {
      _prevIsScrolled = isScrolled;
      _isScrolled.add(isScrolled);
    }
  }

  void clear() {
    _status = EditStatus.none;
    _songs = List.filled(10, null);
    _tempsongs = [..._songs];
  }

  Future<void> getSongs(Playlist playlist) async {
    final keyword = playlist is! Reclist ? playlist.key : playlist.id;
    if (keyword != _prevKeyword) {
      clear();
      _prevKeyword = keyword;
      if (playlist is! Reclist) {
        _songs = (await _api.fetchPlaylistDetail(key: keyword!)).songs;
      } else {
        _songs = (await _api.fetchReclistDetail(key: keyword!)).songs;
      }
      _tempsongs = [..._songs];
      notifyListeners();
    }
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _tempsongs.removeAt(oldIdx);
    _tempsongs.insert(newIdx, song);
    notifyListeners();
  }

  void applySongs(bool? apply) {
    if (apply == null) return;
    if (apply) {
      _songs = [..._tempsongs];
    } else {
      _tempsongs = [..._songs];
    }
    _status = EditStatus.none;
    notifyListeners();
  }
}
