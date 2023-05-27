import 'dart:math';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakmusic/models/errors/error.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models/user.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/services/login.dart';
import 'package:wakmusic/utils/json.dart';

enum LoginStatus { before, after }

enum EditStatus { none, playlists, likes }

class KeepViewModel with ChangeNotifier {
  late User _user;
  LoginStatus _loginStatus = LoginStatus.before;
  EditStatus _editStatus = EditStatus.none;
  String? _prevKeyword;
  late final API _api;
  late final UserRepository _repo;
  late final Future<String> _version;
  late final JSONType<int> profiles;
  late List<Song?> _likes;
  late List<Song?> _tempLikes;
  late List<Playlist?> _playlists;
  late List<Playlist?> _tempPlaylists;

  User get user => _user;
  LoginStatus get loginStatus => _loginStatus;
  EditStatus get editStatus => _editStatus;
  Future<String> get version => _version;
  List<Song?> get likes => _likes;
  List<Song?> get tempLikes => _tempLikes;
  List<Playlist?> get playlists => _playlists;
  List<Playlist?> get tempPlaylists => _tempPlaylists;

  KeepViewModel() {
    _api = API();
    _repo = UserRepository();
    getVersion();
    getProfileList();
  }

  void updateLoginStatus(LoginStatus status) {
    _loginStatus = status;
    notifyListeners();
  }

  void updateEditStatus(EditStatus status) {
    _editStatus = status;
    notifyListeners();
  }

  Future<void> getVersion() async {
    _version = PackageInfo.fromPlatform().then(
      (packageInfo) => packageInfo.version,
    );
    notifyListeners();
  }

  Future<void> getProfileList() async {
    profiles = await _api.getUserProfiles();
  }

  Future<bool?> getUser({Login? platform}) async {
    try {
      final repo = UserRepository();
      if (platform == null && !await repo.isLoggedIn) {
        return null;
      }
      _user = await repo.getUser(platform: platform);
    } catch (e) {
      switch (e) {
        case WakError.loginCancelled:
          return true;
        default:
          print(e);
          return false;
      }
    }
    updateLoginStatus(LoginStatus.after);
    getLists();
    return null;
  }

  void logout() async {
    _user.platform.service.logout();
    updateLoginStatus(LoginStatus.before);
  }

  Future<void> updateUserProfile(String? profile) async {
    if (profile == null) return;
    if (await _repo.setUserProfile(profile)) {
      _user.profile = profile;
    }
    notifyListeners();
  }

  Future<void> updateUserName(String? name) async {
    if (name == null) return;
    if (await _repo.setUserName(name)) {
      _user.displayName = name;
    }
    notifyListeners();
  }

  void clear() {
    _likes = List.filled(10, null);
    _tempLikes = [..._likes];
    _playlists = List.filled(10, null);
    _tempPlaylists = [..._playlists];
  }

  Future<void> getLists() async {
    clear();
    _likes = await _repo.getLikes();
    _playlists = await _repo.getPlaylists();
    _tempLikes = [..._likes];
    _tempPlaylists = [..._playlists];
    notifyListeners();
  }

  Future<void> createList(String? title) async {
    if (title == null) return;
    if (await _repo.createList(title)) {
      _playlists = await _repo.getPlaylists();
      _tempPlaylists = [..._playlists];
    }
    notifyListeners();
  }

  Future<void> loadList(Playlist? playlist) async {
    if (playlist == null) return;
    _playlists.add(playlist);
    _tempPlaylists = [..._playlists];
    notifyListeners();
  }

  Future<void> removeList(Playlist playlist) async {
    if (await _repo.deletePlaylist(playlist.key!)) {
      _playlists.remove(playlist);
      _tempPlaylists = [..._playlists];
    }
    notifyListeners();
  }

  Future<int> addSongs(Playlist playlist, List<Song> songs) async {
    if (playlist is Reclist || songs.isEmpty) {
      return -1;
    }
    
    final addedSongsNum = await _repo.addPlaylistSongs(playlist.key!, songs);

    if (addedSongsNum != -1) {
      final list = songs
          .map((song) => song.id)
          .where((e) => !playlist.songlist!.contains(e));
      playlist.songlist!.addAll(list);
      notifyListeners();
      return addedSongsNum;
    }

    return -1;
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _tempLikes.removeAt(oldIdx);
    _tempLikes.insert(newIdx, song);
    notifyListeners();
  }

  void movePlaylist(int oldIdx, int newIdx) {
    Playlist? playlist = _tempPlaylists.removeAt(oldIdx);
    _tempPlaylists.insert(newIdx, playlist);
    notifyListeners();
  }

  void applyLikes(bool? apply) {
    if (apply == null) return;
    if (apply) {
      _likes = [..._tempLikes];
    } else {
      _tempLikes = [..._likes];
    }
    _editStatus = EditStatus.none;
    notifyListeners();
  }

  Future<void> applyPlaylists(bool? apply) async {
    if (apply == null) return;
    if (apply) {
      final res = await _repo.editPlaylists(
        _tempPlaylists.whereType<Playlist>().toList(),
      );
      if (res) {
        _playlists = [..._tempPlaylists];
      }
    } else {
      _tempPlaylists = [..._playlists];
    }
    _editStatus = EditStatus.none;
    notifyListeners();
  }

  Future<void> updatePlaylist(Playlist old, Playlist updated) async {
    if (old == updated) return;
    _playlists[_playlists.indexOf(old)] = updated;
    notifyListeners();
  }
}
