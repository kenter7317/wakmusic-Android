import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/services/apis/api.dart';

class LikeAPI extends API {
  @override
  String get url => dotenv.get('API_LIKE');

  const LikeAPI();

  Future<int> get({
    required String songId,
  }) async {
    throw '';
  }

  Future<int> add({
    required String songId,
    required String token,
  }) async {
    throw '';
  }

  Future<int> remove({
    required String songId,
    required String token,
  }) async {
    throw '';
  }
}
