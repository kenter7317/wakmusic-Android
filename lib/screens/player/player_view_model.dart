import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

class PlayerViewModel with ChangeNotifier {
  late final API _api;
  late Future<List<String>> _lyrics;

  Future<List<String>> get lyrics => _lyrics;

  PlayerViewModel() {
    _api = API();
    getLyrics();
  }

  Future<void> getLyrics() async {
    _lyrics = _api.getLyrics(id: 'fgSXAKsq-Vo');
    notifyListeners();
  }
}