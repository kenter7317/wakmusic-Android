import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/services/api.dart';

class RecPlaylistProvider extends ChangeNotifier {
  late final API _api;
  late Future<List<Reclist>> _list;

  Future<List<Reclist>> get list => _list;

  RecPlaylistProvider() {
    _api = API();
    getLists();
  }

  Future<void> getLists() async {
    _list = _api.fetchReclists();
    notifyListeners();
  }
}
