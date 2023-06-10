import 'package:wakmusic/models_v2/playlist/reclist.dart';
import 'package:wakmusic/models_v2/playlist/user_playlist.dart';
import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class PlaylistAPI extends API {
  @override
  String get url => dotenv.get('API_PLAYLIST');

  const PlaylistAPI();

  Future<List<Reclist>> get recommendedAll async {
    final url = dotenv.get('API_RECOMMEND');
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Reclist.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<Reclist> recommended({
    required String key,
  }) async {
    final url = dotenv.get('API_RECOMMEND');
    final response = await request('$url/$key', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return Reclist.fromJson(jsonDecode(response.body));
    }

    assert(status.isError);
    throw status;
  }

  Future<String> create({
    required String title,
    required int image,
    required String token,
  }) async {
    final response = await request(
      url,
      method: HttpMethod.post,
      token: token,
      body: {
        'title': title,
        'image': '$image',
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['key'];
    }

    assert(status.isError);
    throw status;
  }

  Future<UserPlaylist> detail({
    required String key,
  }) async {
    final response = await request('$url/$key', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return UserPlaylist.fromJson(jsonDecode(response.body));
    }

    assert(status.isError);
    throw status;
  }

  Future<int> addSongs({
    required String key,
    required List<Song> songs,
    required String token,
  }) async {
    final response = await request(
      '$url/$key/songs/add',
      method: HttpMethod.post,
      token: token,
      strict: true,
      body: listToBody('songs', songs.map((e) => e.id).toList()),
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['addedSongsLength'];
    }

    assert(status.isError);
    throw status;
  }

  Future<void> editSongs({
    required String key,
    required List<Song> songs,
    required String token,
  }) async {
    final response = await request(
      '$url/$key/edit',
      method: HttpMethod.patch,
      token: token,
      strict: true,
      body: listToBody('songs', songs.map((e) => e.id).toList()),
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.patch)) {
      return;
    }

    assert(status.isError);
    throw status;
  }

  Future<String> editTitle({
    required String key,
    required String title,
    required String token,
  }) async {
    final response = await request(
      '$url/$key/edit/title',
      method: HttpMethod.patch,
      token: token,
      body: {
        'title': title,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.patch)) {
      assert(title == jsonDecode(response.body)['title']);
      return jsonDecode(response.body)['title'];
    }

    assert(status.isError);
    throw status;
  }

  Future<void> delete({
    required String key,
    required String token,
  }) async {
    final response = await request(
      '$url/$key/delete',
      method: HttpMethod.delete,
      token: token,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.delete)) {
      return;
    }

    assert(status.isError);
    throw status;
  }

  Future<String> addToMyPlaylist({
    required String key,
    required String token,
  }) async {
    final response = await request(
      '$url/$key/addToMyPlaylist',
      method: HttpMethod.post,
      token: token,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return jsonDecode(response.body)['key'];
    }

    assert(status.isError);
    throw status;
  }
}
