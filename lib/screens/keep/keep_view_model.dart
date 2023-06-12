import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/models_v2/user.dart';
import 'package:wakmusic/repository/user_repo.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/services/login.dart';

enum LoginStatus { before, after }

enum EditStatus { none, playlists, likes }

class KeepViewModel with ChangeNotifier {
  late User _user;
  LoginStatus _loginStatus = LoginStatus.before;
  EditStatus _editStatus = EditStatus.none;
  late final UserRepository _repo;
  late final Future<String> _version;
  late final List<Profile> profiles;
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
    profiles = await API.user.profiles;
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
          log('$e');
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

  Future<void> updateUserProfile(Profile? profile) async {
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
    _likes = [...(await _repo.getLikes()).keys];
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

  Future<void> removeList(UserPlaylist playlist) async {
    if (await _repo.deletePlaylist([playlist])) {
      _playlists.remove(playlist);
      _tempPlaylists = [..._playlists];
    }
    notifyListeners();
  }

  Future<bool> addSongs(Playlist playlist, List<Song> songs) async {
    if (playlist is Reclist || songs.isEmpty) {
      return false;
    }

    if (await _repo.addPlaylistSongs(playlist.key, songs)) {
      final list = songs.where((e) => !playlist.songs!.contains(e));
      playlist.songs!.addAll(list);
      notifyListeners();
      return true;
    }

    return false;
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
        _tempPlaylists.whereType<UserPlaylist>().toList(),
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

  Future<bool> addLikeSong(String songId) async {
    print('진입');
    if(songId.isEmpty) return false;


    var result = await _repo.addLikeSong(songId);

    if(result){
      _likes = [...(await _repo.getLikes()).keys];
      notifyListeners();
    }

    return result;
  }

  Future<bool> removeLikeSong(String songId) async {
    if(songId.isEmpty) return false;

    var result = await _repo.removeLikeSong(songId);

    if(result){
      _likes = [...(await _repo.getLikes()).keys];
      notifyListeners();
    }

    return result;
  }
}
