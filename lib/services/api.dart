import 'dart:convert';
import 'package:http/http.dart' as http;
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

const baseUrl = 'https://wakmusic.xyz/api';
const staticBaseUrl = 'https://static.wakmusic.xyz/static';

class API {

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
}