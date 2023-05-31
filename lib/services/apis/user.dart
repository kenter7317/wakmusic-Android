import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class UserAPI extends API {
  @override
  String get url => dotenv.get('API_USER');

  const UserAPI();

  Future<List<dynamic>> get profiles async {
    throw '';
  }

  Future<void> setProfile({
    required String image,
    required String token,
  }) async {
    throw '';
  }

  Future<void> setUsername({
    required String username,
    required String token,
  }) async {
    throw '';
  }

  Future<List<dynamic>> playlists({
    required String token,
  }) async {
    throw '';
  }

  Future<void> editPlaylists({
    required List<dynamic> playlists,
    required String token,
  }) async {
    throw '';
  }

  Future<void> deletePlaylists({
    required List<dynamic> playlists,
    required String token,
  }) async {
    throw '';
  }

  Future<List<Song>> likes({
    required String token,
  }) async {
    throw '';
  }

  Future<void> editLikes({
    required List<Song> songs,
    required String token,
  }) async {
    throw '';
  }

  Future<void> deleteLikes({
    required List<Song> songs,
    required String token,
  }) async {
    throw '';
  }
}
