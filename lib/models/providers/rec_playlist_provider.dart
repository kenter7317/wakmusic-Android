import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/services/api.dart';

class RecPlaylistProvider extends ChangeNotifier {
  List<Reclist> _list = [];
  List<Reclist> get list => _list;
  bool get isOdd => _list.length.isOdd;
  bool get isEven => _list.length.isEven;
  late final API _api;

  RecPlaylistProvider() {
    _api = API();
  }

  Future<void> getLists() async {
    if (_list.isEmpty) {
      _list = await _api.fetchReclists();
      notifyListeners();
    }
  }
}
