import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/song.dart';

class SelectSongProvider extends ChangeNotifier {
  final List<Song> _list = [];
  List<Song> get list => _list;

  int _maxSel = -1;
  int get maxSel => _maxSel;

  int get selNum => _list.length;

  bool contains(Song targetSong) {
    return _list.where((song) => song.id == targetSong.id).isNotEmpty;
  }

  void setMaxSel(int i) {
    _maxSel = i;
    notifyListeners();
  }

  void addSong(Song song) {
    if (!_list.contains(song)) {
      _list.add(song);
    }
    notifyListeners();
  }

  void addAllSong(List<Song> songs, {bool del = false}) {
    if (del) clearList();
    _list.addAll(songs.where((element) => !_list.contains(element)).toList());
    notifyListeners();
  }

  void removeSong(Song targetSong) {
    _list.removeWhere((song) => song.id == targetSong.id);
    notifyListeners();
  }

  void clearList() {
    _list.clear();
    notifyListeners();
  }
}
