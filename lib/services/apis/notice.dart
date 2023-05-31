import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wakmusic/models_v2/category.dart';
import 'package:wakmusic/models_v2/notice.dart';
import 'package:wakmusic/services/apis/api.dart';

class NoticeAPI extends API {
  @override
  String get url => dotenv.get('API_NOTICE');

  const NoticeAPI();

  Future<List<Category>> get categories async {
    throw '';
  }

  Future<List<Notice>> get display async {
    throw '';
  }

  Future<List<Notice>> get all async {
    throw '';
  }
}
