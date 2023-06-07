import 'package:flutter/material.dart';
import 'package:wakmusic/services/apis/api.dart';
import 'package:wakmusic/models_v2/song.dart';

class ChartsViewModel extends ChangeNotifier {
  late Map<ChartType, Future<DateTime>> _updatedTime;
  late Map<ChartType, Future<List<Song>>> _charts;

  Map<ChartType, Future<DateTime>> get updatedTime => _updatedTime;
  Map<ChartType, Future<List<Song>>> get charts => _charts;

  ChartsViewModel() {
    _charts = {};
    _updatedTime = {};
    getCharts();
  }

  Future<void> getCharts() async {
    for (ChartType type in ChartType.values) {
      _charts[type] = API.charts.top(type: type);
      _updatedTime[type] = API.charts.updatedTime(type: type);
    }
    notifyListeners();
  }
}
