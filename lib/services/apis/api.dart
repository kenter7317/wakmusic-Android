import 'dart:convert';

import 'package:wakmusic/models_v2/enums/http_method.dart';
import 'package:wakmusic/models_v2/enums/http_status.dart';
import 'package:wakmusic/services/apis/artist.dart';
import 'package:wakmusic/services/apis/auth.dart';
import 'package:wakmusic/services/apis/charts.dart';
import 'package:wakmusic/services/apis/common.dart';
import 'package:wakmusic/services/apis/faq.dart';
import 'package:wakmusic/services/apis/like.dart';
import 'package:wakmusic/services/apis/notice.dart';
import 'package:wakmusic/services/apis/playlist.dart';
import 'package:wakmusic/services/apis/songs.dart';
import 'package:wakmusic/services/apis/static.dart';
import 'package:wakmusic/services/apis/suggest.dart';
import 'package:wakmusic/services/apis/user.dart';

import 'package:http/http.dart' as http;
import 'package:wakmusic/utils/json.dart';

class API {
  String get url => throw UnimplementedError('set url');

  const API();

  static const artist = ArtistAPI();
  static const auth = AuthAPI();
  static const charts = ChartsAPI();
  static const faq = FAQAPI();
  static const like = LikeAPI();
  static const notice = NoticeAPI();
  static const playlist = PlaylistAPI();
  static const songs = SongsAPI();
  static const suggest = SuggestAPI();
  static const user = UserAPI();

  static const static = StaticAPI();

  static const _common = CommonAPI();
  static final teams = _common.teams;
  static final check = _common.check;

  Future<http.Response> request(
    String url, {
    required HttpMethod method,
    String? token,
    bool? typeIsJSON,
    JSON? body,
  }) async {
    try {
      final header = {
        if (token != null) 'Authorization': 'Bearer $token',
        if (method != HttpMethod.get && typeIsJSON == true)
          'Content-Type': 'application/json',
      };

      switch (method) {
        case HttpMethod.get:
          return await http.get(Uri.parse(url), headers: header);
        case HttpMethod.post:
          return await http.post(Uri.parse(url), headers: header, body: body);
        case HttpMethod.put:
          return await http.put(Uri.parse(url), headers: header, body: body);
        case HttpMethod.patch:
          return await http.patch(Uri.parse(url), headers: header, body: body);
        case HttpMethod.delete:
          return await http.delete(Uri.parse(url), headers: header, body: body);
      }
    } catch (e) {
      return http.Response('', 404);
    }
  }

  JSON listToBody(String key, List list) {
    return {'"$key"': jsonEncode(list)};
  }
}
