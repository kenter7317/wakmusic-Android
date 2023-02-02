import 'package:flutter/material.dart';
import 'package:wakmusic/services/api.dart';
import 'package:wakmusic/models/song.dart';

class ChartsViewModel extends ChangeNotifier {
  late final API _api;
  late Future<DateTime> _updatedTime;
  late Map<ChartType, Future<List<Song>>> _charts;
  
  Future<DateTime> get updatedTime => _updatedTime;
  Map<ChartType, Future<List<Song>>> get charts => _charts;

  ChartsViewModel() {
    _api = API();
    _charts = {};
    getCharts();
  }

  Future<void> getCharts() async {
    for (ChartType type in ChartType.values) {
      _charts[type] = _api.fetchTop(type: type);
    }
    _updatedTime = _api.fetchUpdatedTime();
    notifyListeners();
  }
}