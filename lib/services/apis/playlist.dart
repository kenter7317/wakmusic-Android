import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/playlist.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class PlaylistAPI extends API {
  @override
  String get url => dotenv.get('API_PLAYLIST');

  const PlaylistAPI();

  Future<List<dynamic>> get recommendedAll async {
    final url = dotenv.get('API_RECOMMEND');
    throw '';
  }

  Future<dynamic> recommended({
    required String key,
  }) async {
    final url = dotenv.get('API_RECOMMEND');
    throw '';
  }

  Future<String> create({
    required String title,
    required int image,
    required String token,
  }) async {
    throw '';
  }

  Future<dynamic> detail({
    required String key,
  }) async {
    throw '';
  }

  Future<dynamic> addSongs({
    required String key,
    required List<Song> songs,
    required String token,
  }) async {
    throw '';
  }

  Future<void> editSongs({
    required String key,
    required List<Song> songs,
    required String token,
  }) async {
    throw '';
  }

  Future<String> editTitle({
    required String key,
    required String title,
    required String token,
  }) async {
    throw '';
  }

  Future<void> delete({
    required String key,
    required String token,
  }) async {
    throw '';
  }

  Future<String> addToMyPlaylist({
    required String key,
    required String token,
  }) async {
    throw '';
  }
}
