import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/api.dart';

enum ScrollState { scrolling, notScrolling }

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  ScrollState _scrollState = ScrollState.notScrolling;

  late Future<SubtitleController> _lyrics;
  String _id = '';
  bool isChanging = false;

  final scrollSnapListKey = GlobalKey<ScrollSnapListState>();
  ScrollState get scrollState => _scrollState;
  Future<SubtitleController> get lyrics => _lyrics;
  bool lyricsEquals(String id) => id == _id;

  PlayerViewModel() {
    _api = API();
  }

  void updateScrollState(ScrollState state) {
    _scrollState = state;
  }

  Future<void> getLyrics(String id) async {
    if (id != _id) {
      _lyrics = _api.getLyrics(id: id);
      _id = id;
    }
  }
}
