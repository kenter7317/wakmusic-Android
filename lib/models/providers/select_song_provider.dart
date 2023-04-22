import 'package:flutter/material.dart';
import 'package:wakmusic/models/song.dart';

class SelectSongProvider extends ChangeNotifier {
  final List<Song> _list = [];
  List<Song> get list => _list;

  int _maxSel = 2; // 수정 (임시로 max 설정)
  int get maxSel => _maxSel;

  int get selNum => _list.length;
  
  bool contains(Song targetSong) {
    return _list.where((song) => song.id == targetSong.id).isNotEmpty;
  }

  void addSong(Song song) {
    _list.add(song);
    notifyListeners();
  }

  void addAllSong() {
    // 수정 (곡 전체에 대한 정보를 넣을 수 없어서 임시로 제작)
    addSong(Song(id: "0", title: "", artist: "", remix: "", reaction: "", date: DateTime(2022), views: 1, last: 1));
    addSong(Song(id: "1", title: "", artist: "", remix: "", reaction: "", date: DateTime(2022), views: 1, last: 1));
    notifyListeners();
  }

  void removeSong(Song targetSong) {
    _list.removeWhere((song) => song.id == targetSong.id);
    notifyListeners();
  }

  void clearList() {
    _list.clear();
    notifyListeners();
  }
}