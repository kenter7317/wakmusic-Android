import 'package:flutter/material.dart';
import 'package:wakmusic/models/song.dart';

class SelectSongProvider extends ChangeNotifier {
  final List<Song> _list = [];
  List<Song> get list => _list;

  bool contains(Song targetSong) {
    return _list.where((song) => song.id == targetSong.id).isNotEmpty;
  }

  void addSong(Song song) {
    _list.add(song);
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