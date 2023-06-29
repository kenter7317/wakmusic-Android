import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wakmusic/models_v2/playlist/playlist.dart';
import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/models_v2/user.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/services/apis/user.dart';
import 'package:wakmusic/services/login.dart';

class UserRepository {
  final FlutterSecureStorage _storage;

  UserRepository({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  Future<String?> get _token => _storage.read(key: 'token');
  Future<bool> get isLoggedIn async => await _token != null;

  Future<User> getUser({Login? platform}) async {
    final cached = await _token;
    assert(platform != null || cached != null);
    try {
      if (cached != null) {
        return await API.auth.get(token: cached);
      }

      final newToken = await API.auth.login(provider: platform!);
      _storage.write(key: 'token', value: newToken);

      return await API.auth.get(token: newToken);
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

  Future<List<UserPlaylist>> getPlaylists() async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      return await API.user.playlists(token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<LikeSong> getLikes() async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      return await API.user.likes(token: token);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> setUserProfile(Profile profile) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.user.setProfile(profile: profile, token: token);
      return true;
    } catch (e) {
      dev.log('$e');
      rethrow;
    }
  }

  Future<bool> setUserName(String name) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.user.setUsername(username: name, token: token);
      return true;
    } catch (e) {
      dev.log('$e');
      rethrow;
    }
  }

  Future<bool> createList(String title) async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      final image = Random().nextInt(11) + 1;
      await API.playlist.create(title: title, image: image, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPlaylist> addToMyPlaylist(String key) async {
    final token = await _token;
    if (token == null) {
      throw HttpStatus.unauthorized;
    }

    try {
      await API.playlist.addToMyPlaylist(key: key, token: token);
      return await API.playlist.detail(key: key);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editPlaylists(List<UserPlaylist> playlists) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.user.editPlaylists(playlists: playlists, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePlaylist(List<UserPlaylist> playlists) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.user.deletePlaylists(playlists: playlists, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> addPlaylistSongs(String key, List<Song> songs) async {
    final token = await _token;
    if (token == null) {
      return -1;
    }

    try {
      return await API.playlist.addSongs(key: key, songs: songs, token: token);
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
      await API.playlist.editSongs(key: key, songs: songs, token: token);
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
      await API.playlist.editTitle(key: key, title: title, token: token);
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
      await API.user.editLikes(songs: songs, token: token);
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
      await API.user.deleteLikes(songs: songs, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addLikeSong(String songId) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.like.add(songId: songId, token: token);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeLikeSong(String songId) async {
    final token = await _token;
    if (token == null) {
      return false;
    }

    try {
      await API.like.remove(songId: songId, token: token);
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
      await platform.service.remove();
      await API.auth.remove(token: token);
      _storage.delete(key: 'token');
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
