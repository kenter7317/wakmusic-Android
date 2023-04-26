import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wakmusic/models/artist.dart';
import 'package:wakmusic/models/faq.dart';
import 'package:wakmusic/models/notice.dart';
import 'package:wakmusic/models/errors/error.dart';
import 'package:wakmusic/models/errors/http_error.dart';
import 'package:wakmusic/models/playlist_detail.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakmusic/models/user.dart';
import 'package:wakmusic/services/login.dart';
import 'package:wakmusic/utils/json.dart';

enum ChartType {
  hourly('시간순'),
  daily('일간순'),
  weekly('주간순'),
  monthly('월간순'),
  total('누적순');

  const ChartType(this.str);
  final String str;
}

enum SearchType {
  title('노래'),
  artist('가수'),
  remix('조교'),
  ids('아이디');

  const SearchType(this.str);
  final String str;
}

enum AlbumType {
  latest("최신순", "new"),
  popular("인기순", "popular"),
  old("과거순", "old");

  const AlbumType(this.kor, this.eng);
  final String kor;
  final String eng;
}

enum GroupType {
  all('전체'),
  woowakgood('우왁굳'),
  isedol('이세돌'),
  gomem('고멤');

  const GroupType(this.locale);
  final String locale;
}

const baseUrl = 'https://wakmusic.xyz/api';
const testBaseUrl = 'https://test.wakmusic.xyz/api';
const staticBaseUrl = 'https://static.wakmusic.xyz/static';

class API {
  Future<http.Response> getResponse(
    String url, {
    String? token,
    JSON? body,
  }) async {
    try {
      return await http.get(
        Uri.parse(url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
    } catch (e) {
      return http.Response('', 404);
    }
  }

  Future<List<Song>> fetchTop({
    required ChartType type,
    int length = 100,
  }) async {
    final response =
        await getResponse('$baseUrl/charts/${type.name}?limit=$length');

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<Song>> fetchNew({required GroupType type}) async {
    final response = await getResponse('$testBaseUrl/songs/new/${type.name}');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    } else {
      throw Exception('New API failed :(');
    }
  }

  Future<DateTime> fetchUpdatedTime() async {
    final response = await getResponse('$baseUrl/updated');
    if (response.statusCode == 200) {
      return DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.body) * 1000);
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<Song>> search({
    required String keyword,
    required SearchType type,
  }) async {
    final response = await getResponse(
        '$baseUrl/search?type=${type.name}&sort=popular&keyword=$keyword');

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<SubtitleController> getLyrics({required String id}) async {
    var controller = SubtitleController(
        provider: SubtitleProvider.fromNetwork(
            Uri.parse('https://wakmusic.xyz/static/lyrics/$id.vtt')));
    await controller.initial();
    return controller;
  }

  @Deprecated('use fetchPlaylistDetail()')
  Future<Playlist> fetchPlaylist({required String key}) async {
    final response = await getResponse('$baseUrl/playlist/detail/$key');
    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<Reclist>> fetchReclists() async {
    final response = await getResponse('$testBaseUrl/playlist/recommended');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Reclist.fromJson(e))
          .toList();
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<PlaylistDetail> fetchPlaylistDetail({required String key}) async {
    final response = await getResponse('$testBaseUrl/playlist/$key/detail');
    if (response.statusCode == 200) {
      return PlaylistDetail.fromJson(jsonDecode(response.body));
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<ReclistDetail> fetchReclistDetail({required String key}) async {
    final response =
        await getResponse('$testBaseUrl/playlist/recommended/$key');
    if (response.statusCode == 200) {
      return ReclistDetail.fromJson(jsonDecode(response.body));
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<String>> fetchFAQCategories() async {
    final response = await getResponse('$testBaseUrl/qna/categories');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => e as String)
          .toList();
    } else {
      throw Exception('FAQ Categories load failed :(');
    }
  }

  Future<List<FAQ>> fetchFAQ() async {
    final response = await getResponse('$testBaseUrl/qna');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => FAQ.fromJson(e))
          .toList();
    } else {
      throw Exception('FAQ load failed :(');
    }
  }

  Future<List<Notice>> fetchNotice() async {
    final response = await getResponse('$testBaseUrl/notice/all');
    if (response.statusCode == 200) {
      return List.from((jsonDecode(response.body) as List)
          .map((e) => Notice.fromJson(e))
          .toList()
          .reversed);
    } else {
      throw Exception('Notice load failed :(');
    }
  }

  Future<String> getToken(Login provider) async {
    final id = await provider.service.login();
    if (id == null) {
      throw WakError.loginCancelled;
    }

    final response = await http.post(
      Uri.parse('$testBaseUrl/auth/login/mobile'),
      body: {
        'id': id,
        'provider': provider.name,
      },
    );

    if (response.statusCode == 201) {
      final token = jsonDecode(response.body)['token'];
      return token;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<User> getUser({required String token}) async {
    final response = await getResponse('$testBaseUrl/auth', token: token);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<JSONType<int>> getUserProfiles() async {
    final response = await getResponse('$testBaseUrl/user/profile/list');

    if (response.statusCode == 200) {
      JSONType<int> profiles = {
        for (var e in jsonDecode(response.body) as List)
          e['type']: e['version'],
      };
      return profiles;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<Artist>> fetchArtists() async {
    final response = await getResponse('$testBaseUrl/artist/list');

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .where((e) => e['id'] != null && e['title'] != null)
          .map((e) => Artist.fromJson(e))
          .toList();
    } else {
      throw Exception('Artists API load failed :(');
    }
  }

  Future<List<Song>> fetchAlbums(String id, String sort, int start) async {
    final response = await getResponse(
        '$testBaseUrl/artist/albums?id=$id&sort=$sort&start=$start');

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    } else {
      throw Exception('Artist Album API load failed :(');
    }
  }

  Future<List<Playlist>> getUserPlaylists({required String token}) async {
    final response =
        await getResponse('$testBaseUrl/user/playlists', token: token);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Playlist.fromJson(e))
          .toList();
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<List<Song>> getLikes({required String token}) async {
    final response = await getResponse('$testBaseUrl/user/likes', token: token);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e['song']))
          .toList();
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> setUserProfile(
    String profile, {
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$testBaseUrl/user/profile/set'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'image': profile},
    );

    if (response.statusCode == 201) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> setUserName(
    String name, {
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$testBaseUrl/user/username'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'username': name},
    );

    if (response.statusCode == 201) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<String> createList(
    String title,
    int image, {
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$testBaseUrl/playlist/create'),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'title': title,
        'image': '$image',
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['key'];
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<bool> addToMyPlaylist(
    key, {
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$testBaseUrl/playlist/$key/addToMyPlaylist'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201) {
      // return jsonDecode(response.body)['key'];
      return true;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<bool> editPlaylists(
    List<String> playlists, {
    required String token,
  }) async {
    final response = await http.patch(
      Uri.parse('$testBaseUrl/user/playlists/edit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: {'"playlists"': jsonEncode(playlists)}.toString(),
    );

    if (response.statusCode == 200) {
      return true;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> deletePlaylist(
    String key, {
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('$testBaseUrl/playlist/$key/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> addPlaylistSongs(
    String key,
    List<String> songs, {
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$testBaseUrl/playlist/$key/songs/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: {'"songs"': jsonEncode(songs)}.toString(),
    );

    if (response.statusCode == 201) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> editPlaylistSongs(
    String key,
    List<String> songs, {
    required String token,
  }) async {
    final response = await http.patch(
      Uri.parse('$testBaseUrl/playlist/$key/edit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: {'"songs"': jsonEncode(songs)}.toString(),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> editPlaylistTitle(
    String key,
    String title, {
    required String token,
  }) async {
    final response = await http.patch(
      Uri.parse('$testBaseUrl/playlist/$key/edit/title'),
      headers: {'Authorization': 'Bearer $token'},
      body: {'title': title},
    );

    if (response.statusCode == 200) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }

  Future<void> removeUser({required String token}) async {
    final response = await http.delete(
      Uri.parse('$testBaseUrl/user/remove'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return;
    }

    throw HttpError.byCode(response.statusCode);
  }
}
