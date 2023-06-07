import 'package:flutter/cupertino.dart';
import 'package:wakmusic/models_v2/playlist/reclist.dart';
import 'package:wakmusic/services/apis/api.dart';

class RecPlaylistProvider extends ChangeNotifier {
  late Future<List<Reclist>> _list;

  Future<List<Reclist>> get list => _list;

  RecPlaylistProvider() {
    _list = API.playlist.recommendedAll;
  }
}
