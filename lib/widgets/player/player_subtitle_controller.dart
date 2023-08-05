import 'dart:convert';

import 'package:http/http.dart';
import 'package:subtitle/subtitle.dart';

class PlayerSubtitleController extends SubtitleController{
  PlayerSubtitleController({required super.provider});

  ISubtitleParser? playerParser;

  @override
  bool get initialized => playerParser != null;

  @override
  Future<void> initial() async {
    if (initialized) return;
    final providerObject = await provider.getSubtitle();
    playerParser = PlayerSubtitlePerser(providerObject);
    subtitles.addAll(playerParser!.parsing());
    sort();
  }
}

class PlayerSubtitleProvider extends SubtitleProvider{

  final Uri url;
  const PlayerSubtitleProvider(this.url);

  @override
  Future<SubtitleObject> getSubtitle() async {

    final response = await get(url);
    if (response.statusCode != 200) {
      throw ErrorInternetFetchingSubtitle(response.statusCode, response.body);
    }

    return SubtitleObject(data: response.body, type: SubtitleType.custom);
  }
}

class PlayerSubtitlePerser extends SubtitleParser{
  PlayerSubtitlePerser(super.object);

  @override
  List<Subtitle> parsing({bool shouldNormalizeText = true}) {
    try{
      return (jsonDecode(object.data) as List)
          .map((item) => Subtitle(
          start: _doubleToDuration(item['start'].toDouble()),
          end: _doubleToDuration(item['end'].toDouble()),
          data: item['text'],
          index: int.parse(item['identifier'])
      )).toList();
    }catch(e){
      print('parsing error : ${e.toString()}');
      var subtitles = List<Subtitle>.empty(growable: true);
      return subtitles;
    }
  }

  Duration _doubleToDuration(double time){

    try{
      List<String> splitTime = time.toString().split('.');
      int millisecond = splitTime.length == 1 ? 0 : int.parse(splitTime[1]);

      return Duration(
          hours: time ~/ 3600,
          minutes: time % 3600 ~/ 60,
          seconds: time % 3600 % 60 ~/ 1,
          milliseconds: millisecond
      );
    }catch(e){
      print('duration error : $e');
      return Duration.zero;
    }
  }
}