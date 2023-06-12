import 'dart:developer';

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
  internalError(500),
  badGateway(502),
  timedOut(522);

  const HttpStatus(this.statusCode);

  final int statusCode;

  bool get isSuccessful => 2 == statusCode ~/ 100;
  bool get isError => {4, 5}.contains(statusCode ~/ 100);
  bool get serverIsDown => {badGateway, timedOut}.contains(this);

  bool valid(HttpMethod method) {
    return isSuccessful && method.code == statusCode;
  }

  factory HttpStatus.byCode(int code) {
    return values.singleWhere(
      (e) => e.statusCode == code,
      orElse: () {
        log('Unknown Http Status Code: $code');
        return unknown;
      },
    );
  }
}
