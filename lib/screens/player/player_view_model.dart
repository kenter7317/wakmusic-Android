import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/apis/api.dart';

import '../../widgets/player/player_scroll_snap_list.dart';

enum ScrollState { scrolling, notScrolling }

class PlayerViewModel with ChangeNotifier {
  ScrollState _scrollState = ScrollState.notScrolling;

  late Future<SubtitleController> _lyrics;
  String _id = '';
  bool isChanging = false;

  final scrollSnapListKey = GlobalKey<PlayerScrollSnapListState>();
  ScrollState get scrollState => _scrollState;
  Future<SubtitleController> get lyrics => _lyrics;
  bool lyricsEquals(String id) => id == _id;

  void updateScrollState(ScrollState state) {
    _scrollState = state;
  }

  Future<void> getLyrics(String id) async {
    if (id != _id) {
      _lyrics = API.songs.lyrics(songId: id);
      _id = id;
    }
  }
}
