import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';

class SelectPlaylistProvider extends ChangeNotifier {
  final List<Playlist> _list = [];
  List<Playlist> get list => _list;

  void addPlaylist(Playlist playlist) {
    _list.add(playlist);
    notifyListeners();
  }

  void removePlaylist(Playlist playlist) {
    _list.remove(playlist);
    notifyListeners();
  }

  void clearList() {
    _list.clear();
    notifyListeners();
  }
}
