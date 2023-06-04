import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakmusic/models_v2/enums/http_status.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:wakmusic/models/playlist_detail.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models/user.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/services/login.dart';

class UserRepository {
  final FlutterSecureStorage _storage;
  final API _api;

  UserRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  })  : _storage = storage,
        _api = API();

  Future<String?> get _token => _storage.read(key: 'token');
  Future<bool> get isLoggedIn async => await _token != null;

  Future<User> getUser({Login? platform}) async {
    final cached = await _token;
    assert(platform != null || cached != null);
    try {
      if (cached != null) {
        return await _api.getUser(token: cached);
      }

      final newToken = await _api.getToken(platform!);
      _storage.write(key: 'token', value: newToken);

      return await _api.getUser(token: newToken);
    } catch (e) {
      _storage.delete(key: 'token');
      switch (e) {
        case HttpStatus.unauthorized:
          return getUser(platform: platform);
        default:
          rethrow;
      }
    }
  }

  Future<List<Playlist>> getPlaylists() async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      return await _api.getUserPlaylists(token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Song>> getLikes() async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      return await _api.getLikes(token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> setUserProfile(String profile) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.setUserProfile(profile, token: token);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> setUserName(String name) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.setUserName(name, token: token);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> createList(String title) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      final image = Random().nextInt(11) + 1;
      final key = await _api.createList(title, image, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaylistDetail> addToMyPlaylist(String key) async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      if (await _api.addToMyPlaylist(key, token: token)) {
        return await _api.fetchPlaylistDetail(key: key);
      }

      throw HttpStatus.badRequest;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editPlaylists(List<Playlist> playlists) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      final list = playlists.map((e) => e.key).whereType<String>().toList();
      await _api.editPlaylists(list, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePlaylist(String key) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.deletePlaylist(key, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addPlaylistSongs(String key, List<Song> songs) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.addPlaylistSongs(
        key,
        songs.map((song) => song.id).toList(),
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editPlaylistSongs(String key, List<Song> songs) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.editPlaylistSongs(
        key,
        songs.map((song) => song.id).toList(),
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editPlaylistTitle(String key, String title) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.editPlaylistTitle(key, title, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editLikeSongs(List<Song> songs) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.editUserLikeSongs(
        songs.map((song) => song.id).toList(),
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteLikeSongs(List<Song> songs) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await _api.editUserLikeSongs(
        songs.map((song) => song.id).toList(),
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeUser(Login platform) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await platform.service.logout();
      await _api.removeUser(token: '');
      _storage.delete(key: 'token');
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
