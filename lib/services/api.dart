import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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

const testBaseUrl = 'https://test.wakmusic.xyz/api';
const baseUrl = 'https://wakmusic.xyz/api';
const staticBaseUrl = 'https://static.wakmusic.xyz/static';

class API {
  Future<http.Response> getResponse(
    String url, {
    JSONType<String>? header,
  }) async {
    try {
      return await http.get(Uri.parse(url), headers: header);
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
    } else {
      throw Exception('Search failed :(');
    }
  }

  Future<SubtitleController> getLyrics({required String id}) async {
    var controller = SubtitleController(
        provider: SubtitleProvider.fromNetwork(
            Uri.parse('https://wakmusic.xyz/static/lyrics/$id.vtt')));
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

  Future<String> getToken(Login provider) async {
    final id = await provider.service.login();
    if (id == null) {
      throw Exception('Login Cancelled By User :\\');
    }

    final response = await http.post(
      Uri.parse('$testBaseUrl/auth/login/mobile'),
      body: {
        'id': id,
        'provider': provider.name,
      },
    );

    if (response.statusCode == 201) {
      final token = (jsonDecode(response.body) as JSON)['token'];
      const FlutterSecureStorage().write(key: 'token', value: token);
      return token;
    } else {
      throw Exception('getToken failed :( ${response.statusCode}');
    }
  }

  Future<User> getUser({required String token}) async {
    final header = {
      'Authorization': 'Bearer $token',
    };
    final response = await getResponse('$testBaseUrl/auth', header: header);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('getUser failed :(');
    }

    // return User(
    //   id: '',
    //   platform: '',
    //   profile: 'panchi',
    //   displayName: '😀😀😀😀😀이모지를 사용한 긴 닉네임',
    //   firstLoginTime: DateTime(1999),
    //   first: true,
    // );
  }
}
