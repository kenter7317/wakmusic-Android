typedef ThrowCallback = void Function(Object?, StackTrace);

class ErrorCatch {
  static ThrowCallback? _method;
  static set method(ThrowCallback? m) => _method = m;

  static void call(Object? error, StackTrace stack) {
    if (_method == null) {
      return;
    }

    _method!(error, stack);
  }
}
