import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wakmusic/models/artist.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models/playlist.dart';

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

class API {
  final String baseUrl = 'https://test.wakmusic.xyz/api';

  Future<http.Response> getResponse(String url) async {
    try {
      return await http.get(Uri.parse(url));
    } catch (e) {
      return http.Response('', 404);
    }
  }

  Future<List<Song>> fetchTop({required ChartType type, int length = 100}) async {
    final response = await getResponse('$baseUrl/charts/${type.name}?limit=$length');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception('Top 100 Chart API failed :(');
    }
  }

  Future<DateTime> fetchUpdatedTime() async {
    final response = await getResponse('$baseUrl/updated');
    if (response.statusCode == 200) {
      return DateTime.fromMillisecondsSinceEpoch(
          int.parse(response.body) * 1000);
    } else {
      throw Exception('Updated Time load failed :(');
    }
  }

  Future<List<Song>> search({required String keyword, required SearchType type}) async {
    final response = await getResponse('$baseUrl/search?type=${type.name}&sort=popular&keyword=$keyword');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception('Search failed :(');
    }
  }

  Future<Playlist> fetchPlaylist({required String key}) async {
    final response = await getResponse('$baseUrl/playlist/detail/$key');
    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Playlist load failed :(');
    }
  }

  Future<List<Artist>> fetchArtists() async {
    final response = await getResponse('$baseUrl/artist/list');

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
    final response =
        await getResponse('$baseUrl/artist/albums?id=$id&sort=$sort&start=$start');

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    } else {
      throw Exception('Artist Album API load failed :(');
    }
  }
}