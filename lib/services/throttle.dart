import 'dart:async';

class Throttle {
  Timer? _throttleTimer;
  late Duration _throttleDuration;

  Throttle({int second = 1}){
    _throttleDuration = Duration(seconds: second);
  }

  void actionFunction(Function function){
    if(_throttleTimer?.isActive ?? false){ return; }
    function();
    _throttleTimer = Timer(_throttleDuration, (){ _throttleTimer = null; });
  }
}