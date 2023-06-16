enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  int get code => {post}.contains(this) ? 201 : 200;
}
