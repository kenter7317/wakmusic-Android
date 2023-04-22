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
    String keyword = [
      "fgSXAKsq-Vo",
      "DPEtmqvaKqY",
      "l8e1Byk1Dx0",
      "K8WC6uWyC9I",
      "6hEvgKL0ClA",
      "JY-gJkMuJ94",
      "08meo6qrhFc",
      "K-5WdjbCYnk",
      "Empfi8q0aas",
      "rFxJjpSeXHI",
      "OTkFJyn4mvc",
      "YmELthNomns",
      "1UbyyaDc8x0",
      "fU8picIMbSk",
      "kra0f71EIgc",
      "-ZFDUHgF48U",
      "--Go33WYnqw",
      "21qpkx17fUw"
    ].join(',');
    if (keyword != _prevKeyword) {
      clear();
      _prevKeyword = keyword;
      _likes = await _api.search(keyword: keyword, type: SearchType.ids);
      _tempLikes = [..._likes];
      _playlists = [
        //await _api.fetchPlaylist(key: 'HqLJwlVQ0M'),
        //await _api.fetchPlaylist(key: 'RfQVp5JdMg'),
      ];
      _tempPlaylists = [..._playlists];
      notifyListeners();
    }
  }

  Future<void> createList(String? title) async {
    if (title == null) return;
    /* call api */
    _playlists.add(Playlist(
      key: '',
      title: title,
      creator: '',
      image: (Random().nextInt(11) + 1).toString(),
      songlist: [],
    ));
    _tempPlaylists = [..._playlists];
    notifyListeners();
  }

  Future<void> loadList(Playlist? playlist) async {
    if (playlist == null) return;
    _playlists.add(playlist);
    _tempPlaylists = [..._playlists];
    notifyListeners();
  }

  Future<void> removeList(Playlist playlist) async {
    _playlists.remove(playlist);
    _tempPlaylists = [..._playlists];
    /* call api */
    notifyListeners();
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

  void applyPlaylists(bool? apply) {
    if (apply == null) return;
    if (apply) {
      _playlists = [..._tempPlaylists];
    } else {
      _tempPlaylists = [..._playlists];
    }
    _editStatus = EditStatus.none;
    notifyListeners();
  }
}