import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';

class SelectPlaylistProvider extends ChangeNotifier {
  final List<UserPlaylist> _list = [];
  // final List<PlaylistDetail> _detailList = [];

  List<Playlist> get list => _list;
  // List<PlaylistDetail> get detailList => _detailList;

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
    // _detailList.clear();
    notifyListeners();
  }
}
