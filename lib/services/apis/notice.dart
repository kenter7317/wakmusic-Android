import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';

class NoticeAPI extends API {
  @override
  String get url => dotenv.get('API_NOTICE');

  const NoticeAPI();

  Future<List<Category>> categories() async {
    throw '';
  }

  Future<List<Notice>> display() async {
    throw '';
  }

  Future<List<Notice>> all() async {
    throw '';
  }
}
