enum HttpError {
  unknown(0),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  conflict(409),
  tooManyRequests(429),
  internal(500);

  const HttpError(this.statusCode);

  final int statusCode;

  factory HttpError.byCode(int code) {
    return values.singleWhere(
      (e) => e.statusCode == code,
      orElse: () {
        print('Unknown Http Status Code: $code');
        return unknown;
      },
    );
  }
}
