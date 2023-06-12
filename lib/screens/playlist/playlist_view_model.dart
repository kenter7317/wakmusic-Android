import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/services/apis/api.dart';

enum EditStatus { none, more, editing }

class PlaylistViewModel with ChangeNotifier {
  EditStatus _status = EditStatus.none;
  late StreamController<bool> _isScrolled;
  bool _prevIsScrolled = false;
  String? _prevKeyword;
  String? title;
  late final UserRepository _repo;
  late List<Song?> _songs;
  late List<Song?> _tempsongs;

  EditStatus get curStatus => _status;
  StreamController<bool> get isScrolled => _isScrolled;
  List<Song?> get songs => _songs;
  List<Song?> get tempsongs => _tempsongs;
  String? get prevKeyword => _prevKeyword;

  PlaylistViewModel() {
    _isScrolled = StreamController<bool>.broadcast();
    _repo = UserRepository();
  }

  void updateStatus(EditStatus status) {
    _status = status;
    notifyListeners();
  }

  void updateScroll(bool isScrolled) {
    if (isScrolled != _prevIsScrolled) {
      _prevIsScrolled = isScrolled;
      _isScrolled.add(isScrolled);
    }
  }

  void clear() {
    _status = EditStatus.none;
    _songs = List.filled(10, null);
    _tempsongs = [..._songs];
  }

  Future<void> getSongs(Playlist playlist) async {
    final keyword = playlist.key;
    if (keyword != _prevKeyword) {
      clear();
      _prevKeyword = keyword;
      if (playlist is Reclist) {
        _songs = (await API.playlist.recommended(key: keyword)).songs!;
      } else {
        await Future.delayed(Duration.zero);
        _songs = [...playlist.songs!];
      }
      _tempsongs = [..._songs];
      notifyListeners();
    }
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _tempsongs.removeAt(oldIdx);
    _tempsongs.insert(newIdx, song);
    notifyListeners();
  }

  void removeSongs(List<Song> songs) async {
    for (var song in songs) {
      tempsongs.remove(song);
    }
    await applySongs(true);
    print(tempsongs.length);
    _status = EditStatus.none;
    notifyListeners();
  }

  Future<void> applySongs(bool? apply) async {
    if (apply == null) return;
    if (apply) {
      final res = await _repo.editPlaylistSongs(
        _prevKeyword!,
        _tempsongs.whereType<Song>().toList(),
      );
      if (res) {
        _songs = [..._tempsongs];
      }
    } else {
      _tempsongs = [..._songs];
    }
    _status = EditStatus.none;
    notifyListeners();
  }

  Future<void> updateTitle(String? newTitle) async {
    if (newTitle == null) return;
    if (await _repo.editPlaylistTitle(_prevKeyword!, newTitle)) {
      title = newTitle;
      notifyListeners();
    }
  }
}
