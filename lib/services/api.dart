import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wakmusic/models/faq.dart';
import 'package:wakmusic/models/notice.dart';
import 'package:wakmusic/models/song.dart';
import 'package:wakmusic/models/playlist.dart';
import 'package:subtitle/subtitle.dart';

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

  Future<List<Song>> fetchNew({required GroupType type}) async {
    final response = await getResponse('$testBaseUrl/songs/new/${type.name}');
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception('New API failed :(');
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

  Future<SubtitleController> getLyrics({required String id}) async {
    var controller = SubtitleController(provider: SubtitleProvider.fromNetwork(Uri.parse('https://wakmusic.xyz/static/lyrics/$id.vtt')));
    await controller.initial();
    return controller;
  }

  Future<Playlist> fetchPlaylist({required String key}) async {
    final response = await getResponse('$baseUrl/playlist/detail/$key');
    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Playlist load failed :(');
    }
  }

  Future<List<String>> fetchFAQCategories() async {
    final response = await getResponse('$testBaseUrl/qna/categories');
    if (response.statusCode == 200) {
      return(jsonDecode(response.body) as List).map((e) => e as String).toList();
    } else {
      throw Exception('FAQ Categories load failed :(');
    }
  }

  Future<List<FAQ>> fetchFAQ() async {
    final response = await getResponse('$testBaseUrl/qna');
    if (response.statusCode == 200) {
      return(jsonDecode(response.body) as List).map((e) => FAQ.fromJson(e)).toList();
    } else {
      throw Exception('FAQ load failed :(');
    }
  }

  Future<List<Notice>> fetchNotice() async {
    final response = await getResponse('$testBaseUrl/notice/all');
    if (response.statusCode == 200) {
      return List.from((jsonDecode(response.body) as List).map((e) => Notice.fromJson(e)).toList().reversed);
    } else {
      throw Exception('Notice load failed :(');
    }
  }
}