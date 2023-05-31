import 'package:wakmusic/models_v2/song.dart';
import 'package:wakmusic/services/apis/api.dart';

class PlaylistAPI extends API {
  @override
  String get url => dotenv.get('API_PLAYLIST');

  const PlaylistAPI();

  Future<List<dynamic>> get recommendedAll async {
    final url = dotenv.get('API_RECOMMEND');
    final response = await request(url, method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      // return (jsonDecode(response.body) as List)
      //     .map((e) => Reclist.fromJson(e))
      //     .toList();
      throw 'API.playlist.detail :: Update Reclist (models_v2)';
    }

    assert(status.isError);
    throw status;
  }

  Future<dynamic> recommended({
    required String key,
  }) async {
    final url = dotenv.get('API_RECOMMEND');
    final response = await request('$url/$key', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      // return Reclist.fromJson(jsonDecode(response.body));
      throw 'API.playlist.detail :: Update Reclist (models_v2)';
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

  Future<dynamic> detail({
    required String key,
  }) async {
    final url = dotenv.get('API_RECOMMEND');
    final response = await request('$url/$key', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      // return Playlist.fromJson(jsonDecode(response.body));
      throw 'API.playlist.detail :: Update Playlist (models_v2)';
    }

    assert(status.isError);
    throw status;
  }

  Future<dynamic> addSongs({
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
      // return jsonDecode(response.body)['addedSongsLength'];
      // return jsonDecode(response.body)['duplicated'];
      // return;
      throw 'API.playlist.addSongs :: Update required';
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
