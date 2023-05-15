import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/api.dart';

enum ScrollState { scrolling, notScrolling }

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  ScrollState _scrollState = ScrollState.notScrolling;

  late SubtitleController _lyrics;
  String _id = '';

  ScrollState get scrollState => _scrollState;
  SubtitleController get lyrics => _lyrics;
  bool lyricsEquals(String id) => id == _id;

  PlayerViewModel() {
    _api = API();
  }

  void updateScrollState(ScrollState state) {
    _scrollState = state;
  }

  Future<void> getLyrics(String id) async {
    if (id != _id) {
      _lyrics = await _api.getLyrics(id: id);
      _id = id;
      notifyListeners();
    }
  }
}
