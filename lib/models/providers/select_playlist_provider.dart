import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';

class SelectPlaylistProvider extends ChangeNotifier {
  final List<UserPlaylist> _list = [];

  List<UserPlaylist> get list => _list;

  void addPlaylist(UserPlaylist playlist) {
    _list.add(playlist);
    notifyListeners();
  }

  void removePlaylist(UserPlaylist playlist) {
    _list.remove(playlist);
    notifyListeners();
  }

  void clearList() {
    _list.clear();
    notifyListeners();
  }
}
