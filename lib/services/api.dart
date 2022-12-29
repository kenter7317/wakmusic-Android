import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wakmusic/models/song.dart';

enum ChartType {
  total('누적'),
  hourly('시간'),
  daily('일간'),
  weekly('주간'),
  monthly('월간');

  const ChartType(this.locale);
  final String locale;
}

enum SearchType {
  title("노래"),
  artist("가수"),
  remix("조교"),
  ids("아이디");

  const SearchType(this.str);
  final String str;
}

class API {
  final String baseUrl = 'https://wakmusic.xyz/api';

  Future<http.Response> getResponse(String url) async {
    try {
      return await http.get(Uri.parse(url));
    } catch (e) {
      return http.Response('', 404);
    }
  }

  Future<List<Song>> fetchTop(
      {required ChartType type, int length = 100}) async {
    final response =
        await getResponse('$baseUrl/charts/${type.name}?limit=$length');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    } else {
      throw Exception('Top 100 Chart API failed :(');
    }
  }

  Future<List<Song>> search(String keyword, SearchType type) async {
    final response = await getResponse(
        '$baseUrl/search?type=${type.name}&sort=popular&keyword=$keyword');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Song.fromJson(e))
          .toList();
    } else {
      throw Exception('Search failed :(');
    }
  }
}