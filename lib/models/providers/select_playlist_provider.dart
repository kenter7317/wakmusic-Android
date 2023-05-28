import 'package:flutter/material.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/models/playlist_detail.dart';
import 'package:wakmusic/services/api.dart';

class SelectPlaylistProvider extends ChangeNotifier {
  final List<Playlist> _list = [];
  final List<PlaylistDetail> _detailList = [];
  final _api = API();

  List<Playlist> get list => _list;
  List<PlaylistDetail> get detailList => _detailList;

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
    _detailList.clear();
    notifyListeners();
  }

  Future<void> getDetailPlaylist() async {
    for (var i = 0; i < _list.length; i++) {
      _detailList.add(await _api.fetchPlaylistDetail(key: _list[i].key!));
    }
  }
}
