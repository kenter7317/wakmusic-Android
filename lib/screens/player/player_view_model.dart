import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/api.dart';

enum ScrollState { scrolling, notScrolling }

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  ScrollState _scrollState = ScrollState.notScrolling;

  late Future<SubtitleController> _lyrics;

  ScrollState get scrollState => _scrollState;
  Future<SubtitleController> get lyrics => _lyrics;

  PlayerViewModel() {
    _api = API();
  }

  void updateScrollState(ScrollState state){
    _scrollState = state;
  }

  Future<void> getLyrics(String id) async {
    _lyrics = _api.getLyrics(id: id);
  }
}