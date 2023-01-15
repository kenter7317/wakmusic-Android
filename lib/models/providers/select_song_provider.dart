import 'package:flutter/material.dart';
import 'package:wakmusic/models/song.dart';

class SelectSongProvider extends ChangeNotifier {
  final List<Song> _list = [];
  List<Song> get list => _list;

  void addSong(Song song) {
    _list.add(song);
    notifyListeners();
  }

  void removeSong(Song song) {
    _list.remove(song);
    notifyListeners();
  }

  void clearList() {
    _list.clear();
    notifyListeners();
  }
}