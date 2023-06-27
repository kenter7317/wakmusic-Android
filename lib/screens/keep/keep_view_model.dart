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
  late List<UserPlaylist?> _playlists;
  late List<UserPlaylist?> _tempPlaylists;

  User get user => _user;
  LoginStatus get loginStatus => _loginStatus;
  EditStatus get editStatus => _editStatus;
  Future<String> get version => _version;
  List<Song?> get likes => _likes;
  List<Song?> get tempLikes => _tempLikes;
  List<UserPlaylist?> get playlists => _playlists;
  List<UserPlaylist?> get tempPlaylists => _tempPlaylists;

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
          // return false;
          rethrow;
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

  Future<void> loadList(UserPlaylist? playlist) async {
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

  Future<int> addSongs(UserPlaylist playlist, List<Song> songs) async {
    if (playlist is Reclist || songs.isEmpty) {
      return -1;
    }

    try {
      final addedSongsNum = await _repo.addPlaylistSongs(playlist.key, songs);
      if (addedSongsNum != -1) {
        final list = songs.where((e) => !playlist.songs.contains(e));
        playlist.songs.addAll(list);
        notifyListeners();
        return addedSongsNum;
      }
    } catch (e) {
      return -2; // 서버측의 전곡 중복에 대한 에러 미처리로 인한 임시 조치
    }
    
    return -1;
  }

  void moveSong(int oldIdx, int newIdx) {
    Song? song = _tempLikes.removeAt(oldIdx);
    _tempLikes.insert(newIdx, song);
    notifyListeners();
  }

  void movePlaylist(int oldIdx, int newIdx) {
    UserPlaylist? playlist = _tempPlaylists.removeAt(oldIdx);
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

  Future<void> updatePlaylist(UserPlaylist old, UserPlaylist updated) async {
    if (old == updated) return;
    _playlists[_playlists.indexOf(old)] = updated;
    notifyListeners();
  }

  void deleteLikeSongs(List<Song> songs) {
    _repo.deleteLikeSongs(songs);
    notifyListeners();
  }

  Future<bool> addLikeSong(String songId) async {
    if (songId.isEmpty) return false;

    var result = await _repo.addLikeSong(songId);

    if (result) {
      _likes = [...(await _repo.getLikes()).keys];
      notifyListeners();
    }

    return result;
  }

  Future<bool> removeLikeSong(String songId) async {
    if (songId.isEmpty) return false;

    var result = await _repo.removeLikeSong(songId);

    if (result) {
      _likes = [...(await _repo.getLikes()).keys];
      notifyListeners();
    }

    return result;
  }
}
