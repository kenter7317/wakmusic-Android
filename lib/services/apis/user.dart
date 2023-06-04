import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models_v2/profile.dart';
import 'package:wakmusic/services/apis/api.dart';

class UserAPI extends API {
  @override
  String get url => dotenv.get('API_USER');

  const UserAPI();

  Future<List<Profile>> get profiles async {
    final response = await request('$url/profile/list', method: HttpMethod.get);

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => Profile.fromJson(e))
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<void> setProfile({
    required Profile profile,
    required String token,
  }) async {
    final response = await request(
      '$url/profile/set',
      method: HttpMethod.post,
      token: token,
      body: {
        'image': profile.type,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return;
    }

    assert(status.isError);
    throw status;
  }

  Future<void> setUsername({
    required String username,
    required String token,
  }) async {
    final response = await request(
      '$url/profile/set',
      method: HttpMethod.post,
      token: token,
      body: {
        'username': username,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.post)) {
      return;
    }

    assert(status.isError);
    throw status;
  }

  Future<List<dynamic>> playlists({
    required String token,
  }) async {
    final response = await request(
      '$url/playlists',
      method: HttpMethod.get,
      token: token,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      // return (jsonDecode(response.body) as List)
      //     .map((e) => Profile.fromJson(e))
      //     .toList();
      throw 'API.user.playlists :: Update Playlist (models_v2)';
    }

    assert(status.isError);
    throw status;
  }

  Future<void> editPlaylists({
    required List<dynamic> playlists,
    required String token,
  }) async {
    final response = await request(
      '$url/playlists/edit',
      method: HttpMethod.patch,
      token: token,
      strict: true,
      body: listToBody('playlists', playlists.map((e) => e.key).toList()),
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.patch)) {
      throw 'API.user.editPlaylists :: Update required';
    }

    assert(status.isError);
    throw status;
  }

  Future<void> deletePlaylists({
    required List<dynamic> playlists,
    required String token,
  }) async {
    final response = await request(
      '$url/playlists/delete',
      method: HttpMethod.delete,
      token: token,
      strict: true,
      body: listToBody('playlists', playlists.map((e) => e.key).toList()),
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.delete)) {
      throw 'API.user.deletePlaylists :: Update required';
    }

    assert(status.isError);
    throw status;
  }

  Future<List<Map<Song, int>>> likes({
    required String token,
  }) async {
    final response = await request(
      '$url/likes',
      method: HttpMethod.get,
      token: token,
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.get)) {
      return (jsonDecode(response.body) as List)
          .map((e) => {Song.fromJson(e['song']): e['likes'] as int})
          .toList();
    }

    assert(status.isError);
    throw status;
  }

  Future<void> editLikes({
    required List<Song> songs,
    required String token,
  }) async {
    final response = await request(
      '$url/likes/edit',
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

  Future<void> deleteLikes({
    required List<Song> songs,
    required String token,
  }) async {
    final response = await request(
      '$url/likes/delete',
      method: HttpMethod.delete,
      token: token,
      strict: true,
      body: listToBody('songs', songs.map((e) => e.id).toList()),
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.delete)) {
      return;
    }

    assert(status.isError);
    throw status;
  }
}
