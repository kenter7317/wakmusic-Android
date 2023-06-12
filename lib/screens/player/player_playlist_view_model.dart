import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/song.dart';

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
}
