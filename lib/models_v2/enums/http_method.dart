enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  int get code => {post, delete}.contains(this) ? 201 : 200;
}
