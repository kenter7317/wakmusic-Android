import 'dart:convert';

import 'package:wakmusic/services/apis/api.dart';

class SuggestAPI extends API {
  @override
  String get url => dotenv.get('API_SUGGEST');

  const SuggestAPI();

  Future<String> bugReport({
    required String userId,
    String? nickname,
    List<String>? attaches,
    required String detailContent,
    String? deviceModel,
    String? osVersion,
  }) async {
    final response = await request(
      '$url/bug',
      method: HttpMethod.put,
      strict: true,
      body: {
        '"userId"': userId,
        if (nickname != null) '"nickname"': nickname,
        if (attaches != null) '"attachs"': jsonEncode(attaches),
        '"detainContent"': detailContent,
        if (deviceModel != null) '"deviceModel"': deviceModel,
        if (osVersion != null) '"osVersion"': osVersion,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.put)) {
      return jsonDecode(response.body)['message'];
    }

    assert(status.isError);
    throw status;
  }

  Future<String> feature({
    required String userId,
    String platform = 'MOBILE',
    required String detailContent,
  }) async {
    final response = await request(
      '$url/feature',
      method: HttpMethod.put,
      strict: true,
      body: {
        '"userId"': userId,
        '"platform"': platform,
        '"detainContent"': detailContent,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.put)) {
      return jsonDecode(response.body)['message'];
    }

    assert(status.isError);
    throw status;
  }

  Future<String> weekly({
    required String userId,
    required String detailContent,
  }) async {
    final response = await request(
      '$url/bug',
      method: HttpMethod.put,
      strict: true,
      body: {
        '"userId"': userId,
        '"detainContent"': detailContent,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.put)) {
      return jsonDecode(response.body)['message'];
    }

    assert(status.isError);
    throw status;
  }

  Future<String> music({
    required String userId,
    bool update = false, // type 기본값 add
    String? artist,
    String? title,
    String? youtubeLink,
    required String detailContent,
  }) async {
    final response = await request(
      '$url/bug',
      method: HttpMethod.put,
      strict: true,
      body: {
        '"userId"': userId,
        '"type"': update ? 'UPDATE' : 'ADD',
        if (artist != null) '"artist"': artist,
        if (title != null) '"title"': title,
        if (youtubeLink != null) '"youtubeLink"': youtubeLink,
        '"detainContent"': detailContent,
      },
    );

    final status = HttpStatus.byCode(response.statusCode);
    if (status.valid(HttpMethod.put)) {
      return jsonDecode(response.body)['message'];
    }

    assert(status.isError);
    throw status;
  }
}
