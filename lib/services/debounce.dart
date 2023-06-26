import 'dart:async';

class Debounce {
  Timer? _debounceTimer;
  late Duration _debounceDuration;

  Debounce({int milliseconds = 1000}){
    _debounceDuration = Duration(milliseconds: milliseconds);
  }

  void actionFunction(Function function){
    if(_debounceTimer != null){
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(_debounceDuration, (){
      function();
    });
  }
}