import 'package:wakmusic/models_v2/enums/http_method.dart';

enum HttpStatus {
  unknown(0),

  ok(200),
  created(201),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  conflict(409),
  tooManyRequests(429),
  internal(500);

  const HttpStatus(this.statusCode);

  final int statusCode;

  bool get isSuccessful => 2 == statusCode ~/ 100;
  bool get isError => {4, 5}.contains(statusCode ~/ 100);

  bool valid(HttpMethod method) {
    return isSuccessful && method.code == statusCode;
  }

  factory HttpStatus.byCode(int code) {
    return values.singleWhere(
      (e) => e.statusCode == code,
      orElse: () {
        print('Unknown Http Status Code: $code');
        return unknown;
      },
    );
  }
}
