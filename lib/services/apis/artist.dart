import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/artist.dart';
import 'package:wakmusic/models_v2/enums/types.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class ArtistAPI extends API {
  @override
  String get url => dotenv.get('API_ARTIST');

  const ArtistAPI();

  Future<List<Artist>> list() async {
    throw '';
  }

  Future<List<Song>> albums({
    required String id,
    required AlbumType sort,
    int start = 0,
  }) async {
    throw '';
  }
}
