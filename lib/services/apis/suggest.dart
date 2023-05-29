import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/services/apis/api.dart';

class SuggestAPI extends API {
  @override
  String get url => dotenv.get('API_SUGGEST');

  const SuggestAPI();

  Future<void> bugReport({
    required String userId,
    String? nickname,
    List<String>? attaches,
    required String detailContent,
    String? deviceModel,
    String? osVersion,
  }) async {
    throw '';
  }

  Future<void> feature({
    required String userId,
    String platform = 'MOBILE',
    required String detailContent,
  }) async {
    throw '';
  }

  Future<void> weekly({
    required String userId,
    required String detailContent,
  }) async {
    throw '';
  }

  Future<void> music({
    required String userId,
    bool update = false, // type 기본값 add
    String? artist,
    String? title,
    String? youtubeLink,
    required String detailContent,
  }) async {
    throw '';
  }
}
