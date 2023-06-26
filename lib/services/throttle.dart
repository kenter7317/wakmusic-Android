import 'dart:async';

class Throttle {
  Timer? _throttleTimer;
  late Duration _throttleDuration;

  Throttle({int milliseconds = 1000}){
    _throttleDuration = Duration(milliseconds: milliseconds);
  }

  void actionFunction(Function function){
    if(_throttleTimer?.isActive ?? false){ return; }
    function();
    _throttleTimer = Timer(_throttleDuration, (){ _throttleTimer = null; });
  }
}