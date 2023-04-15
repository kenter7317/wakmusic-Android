import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wakmusic/models/errors/error.dart';
import 'package:wakmusic/models/errors/http_error.dart';
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
    String? token,
    JSON? body,
  }) async {
    try {
      return await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<Playlist> fetchPlaylist({required String key}) async {
    final response = await getResponse('$baseUrl/playlist/detail/$key');
    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    }

    throw HttpError.byCode(response.statusCode);
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
}
