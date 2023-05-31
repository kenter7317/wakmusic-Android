enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  int get code => {get, put}.contains(this) ? 200 : 201;
}
