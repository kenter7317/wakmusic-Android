import 'package:flutter/material.dart';
import 'package:wakmusic/models/song.dart';

enum PageState { normal, edit }

class PlayerPlayListViewModel with ChangeNotifier {
  PageState _state = PageState.normal;
  late List<Song> _playlist;

  List<Song> get playList => _playlist;
  PageState get state => _state;

  void updateStatus(PageState state) {
    _state = state;
    notifyListeners();
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _playlist.removeAt(oldIdx);
    _playlist.insert(newIdx, song);
    notifyListeners();
  }

  void setList(List<Song> list){
    _playlist = [...list];
    notifyListeners();
  }
}