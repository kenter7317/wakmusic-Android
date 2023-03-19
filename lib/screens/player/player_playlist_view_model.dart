import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/services/api.dart';

import '../playlist/playlist_view_model.dart';

enum PageState { normal, edit}

class PlayerPlayListViewModel with ChangeNotifier {
  PageState _state = PageState.normal;
  late Future<List<Song>> _playlist;
  late final API _api;

  Future<List<Song>> get playList => _playlist;
  PageState get state => _state;

  PlayerPlayListViewModel() {
    // 초기화 부분
    _api = API();
    getList();
  }

  void updateStatus(PageState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> getList() async {
    _playlist = _api.fetchTop(type: ChartType.hourly);
    notifyListeners();
  }
}