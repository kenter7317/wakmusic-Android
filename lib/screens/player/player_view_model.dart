import 'package:flutter/material.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/services/api.dart';

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  late Future<SubtitleController> _lyrics;

  Future<SubtitleController> get lyrics => _lyrics;

  PlayerViewModel() {
    _api = API();
    getLyrics('fgSXAKsq-Vo');
  }

  Future<void> getLyrics(String id) async {
    _lyrics = _api.getLyrics(id: id);
    notifyListeners();
  }
}